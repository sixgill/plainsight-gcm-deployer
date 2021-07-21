GO_DEVPATH=$HOME/development/go/src/github.com/sixgill
NODE_DEVPATH=$HOME/development/js
DEPLOYERPATH=$GO_DEVPATH/plainsight-marketplace-deployer

mkdir -p $DEPLOYERPATH/docs
cp -r $GO_DEVPATH/sense-api/docs/licenses/* $DEPLOYERPATH/docs/
cp -r $GO_DEVPATH/sense-billing-service/docs/licenses/* $DEPLOYERPATH/docs/

rm -f $DEPLOYERPATH/docs/all.csv

for SVC in api billing migrator worker
do
    cat $DEPLOYERPATH/docs/$SVC/$SVC.csv >> $DEPLOYERPATH/docs/all.csv
done