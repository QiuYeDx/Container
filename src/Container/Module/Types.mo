module{
    public type Asset = {
        data : Blob;
        total_size : Nat;
        extension : FileExtension;
    };

    public type AssetExt = {
        key : Text;
        canister_id : Principal;
    };


    public type FileExtension = {
        #txt;
        #docs;
        #doc;
        #ppt;
        #jpeg;
        #jpg;
        #png;
        #gif;
        #svg;
        #mp3;
        #wav;
        #aac;
        #mp4;
        #avi;
    };

};