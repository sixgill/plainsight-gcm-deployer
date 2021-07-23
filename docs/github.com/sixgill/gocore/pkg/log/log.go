package log

import (
	"os"
	"strings"

	"github.com/kelseyhightower/envconfig"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var (
	Logger            *zap.Logger
	hostname          string
	statLogLevelCount = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "log_level_total",
			Help: "Number of log statements, differentiated by log level.",
		},
		[]string{"level"})
)

type Config struct {
	LogLevel string `envconfig:"LOGGER_LEVEL" default:"info"`
}

func logLevel(level string) zap.AtomicLevel {
	var atomicLevel zap.AtomicLevel
	switch strings.ToLower(level) {
	case "debug":
		atomicLevel = zap.NewAtomicLevelAt(zap.DebugLevel)
	case "info":
		atomicLevel = zap.NewAtomicLevelAt(zap.InfoLevel)
	case "warn", "warning":
		atomicLevel = zap.NewAtomicLevelAt(zap.WarnLevel)
	case "error", "err":
		atomicLevel = zap.NewAtomicLevelAt(zap.ErrorLevel)
	case "fatal":
		atomicLevel = zap.NewAtomicLevelAt(zap.FatalLevel)
	case "panic":
		atomicLevel = zap.NewAtomicLevelAt(zap.PanicLevel)
	default:
		atomicLevel = zap.NewAtomicLevelAt(zap.InfoLevel)
	}
	return atomicLevel
}

func Level(level string) zapcore.Level {

	var coreLevel zapcore.Level
	switch strings.ToLower(level) {
	case "debug":
		coreLevel = zapcore.DebugLevel
	case "info":
		coreLevel = zapcore.InfoLevel
	case "warn", "warning":
		coreLevel = zapcore.WarnLevel
	case "error", "err":
		coreLevel = zapcore.ErrorLevel
	case "fatal":
		coreLevel = zapcore.FatalLevel
	case "panic":
		coreLevel = zapcore.PanicLevel
	default:
		coreLevel = zapcore.InfoLevel
	}
	return coreLevel
}

func newLogger(level string) *zap.Logger {
	cfg := zap.Config{
		Level:            logLevel(strings.ToLower(level)),
		Encoding:         "json",
		DisableCaller:    true,
		OutputPaths:      []string{"stdout"},
		ErrorOutputPaths: []string{"stderr"},
		EncoderConfig: zapcore.EncoderConfig{
			NameKey:       "logger",
			StacktraceKey: "stacktrace",
			MessageKey:    "msg",
			LevelKey:      "level",
			EncodeLevel:   zapcore.LowercaseLevelEncoder,
			TimeKey:       "ts",
			EncodeTime:    zapcore.ISO8601TimeEncoder,
			CallerKey:     "caller",
			EncodeCaller:  zapcore.ShortCallerEncoder,
		},
	}

	logger, err := cfg.Build(zap.WrapCore(func(core zapcore.Core) zapcore.Core {
		return zapcore.RegisterHooks(core, func(e zapcore.Entry) error {
			statLogLevelCount.WithLabelValues(e.Level.String()).Inc()
			return nil
		})
	}))

	if err != nil {
		panic(err)
	}

	return logger.With(zap.String("hostname", hostname))
}

func init() {

	var (
		err error
		c   Config
	)

	hostname, err = os.Hostname()
	if hostname == "" || err != nil {
		hostname = "localhost"
	}

	configErr := envconfig.Process("", &c)
	// we still create a logger, even if the config fails, defaults to "Info"
	Logger = newLogger(c.LogLevel)
	if configErr != nil {
		Logger.Error("failed to create new logger", zap.Error(configErr))
	}
	Logger.Info("Initialized Zap Logger", zap.String("level", c.LogLevel))
}
