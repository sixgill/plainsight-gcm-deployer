GO_DEVPATH=$HOME/development/go/src/github.com/sixgill
DEPLOYERPATH=$GO_DEVPATH/plainsight-marketplace-deployer

rm -rf docs

mkdir -p $DEPLOYERPATH/docs
cp -r $GO_DEVPATH/sense-api/vendor/* $DEPLOYERPATH/docs/
cp -r $GO_DEVPATH/sense-billing-service/vendor/* $DEPLOYERPATH/docs/