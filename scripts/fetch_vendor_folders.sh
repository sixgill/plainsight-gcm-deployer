GO_DEVPATH=$HOME/development/go/src/github.com/sixgill
DEPLOYERPATH=$GO_DEVPATH/plainsight-marketplace-deployer

rm -rf docs

mkdir -p $DEPLOYERPATH/docs

cd $GO_DEVPATH/sense-api && git stash && git checkout main && git pull && go mod vendor
cd $GO_DEVPATH/sense-billing-service && git stash && git checkout master && git pull && go mod vendor
cd $DEPLOYERPATH

cp -r $GO_DEVPATH/sense-api/vendor/* $DEPLOYERPATH/docs/
cp -r $GO_DEVPATH/sense-billing-service/vendor/* $DEPLOYERPATH/docs/