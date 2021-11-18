
shared({caller}) actor class Bucket() = this{

    private type Asset = Types.Asset;

    // key - value
    let map = HashMap.HashMap<Text, Asset>(100, Text.equal, Text.hash);

    //https://github.com/Di-Box/AutoScale-Storage/blob/main/Bucket/src/Bucket/Bucket.mo
    // generate asset struct
    private func _asset( params ) : Asset{

    };

    // 
    public shared({caller}) func put(key : Text, data : Blob) : async Result.Result<AssetExt, Text>{
        #ok(_asset( param ))
    };

    public query({caller}) func get(key : Text) : async Result.Result<Asset, Text>{

    };

    //https://smartcontracts.org/docs/language-guide/upgrades.html
    system func preupgrade(){

    };

    system func postupgrade(){

    };





};