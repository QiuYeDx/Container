import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Prim "mo:⛔";
import Types "../Module/Types";
import Iter "mo:base/Iter";
import TrieSet "mo:base/TrieSet";

shared({caller}) actor class Bucket(init_owner_ : [Principal]) = this{

    private type Asset = Types.Asset;
    private type AssetExt = Types.AssetExt;
    private type FileExtension = Types.FileExtension;
    private let cycle_limit = 2_000_000_000_000;

    // key - value
    private stable var map = HashMap.HashMap<Text, Asset>(100, Text.equal, Text.hash);
    private stable var owners = TrieSet.fromArray<Principal>(init_owner_, Principal.hash, Principal.equal);
    //https://github.com/Di-Box/AutoScale-Storage/blob/main/Bucket/src/Bucket/Bucket.mo
    // generate asset struct
    private func asset(dt : [Blob], sz : Nat, tp : FileExtension) : Asset {
        {
            data = dt;
            total_size = sz;
            extension = tp;
        }
    };

    private func _asset(key : Text, canister_id : Principal) : AssetExt {
        {
            key = key;
            canister_id = canister_id;
        }
    };

    private func isOwner(u : Principal) : Bool{
        if(TrieSet.mem<Principal>(owners, u, Principal.hash(u), Principal.equal)){ return true };
        false
    };

    // 
    public shared({caller}) func put(key : Text, dt : [Blob], sz : Nat, tp : FileExtension, append : Bool) : async Result.Result<AssetExt, Text>{
        if (not isOwner(caller)) { return #err("you are not the owner of this Bucket") };
        if (append) {
            let pre = switch(map.get(key)) {
                case null { [] };
                case (?Asset) { Asset.data };
            };
            let osz = switch(map.get(key)) {
                case null { 0 };
                case (?Asset) { Asset.total_size };
            }
            let new_dt = Array.append<Blob>(pre, dt);
            let new_size = sz + osz;
            let nAs = asset(new_dt, new_size, tp);
            map.put(key, nAs);
        } else {
            let nAs = asset(dt, sz, tp);
            map.put(key, nAs);
        };
        #ok(_asset(key, Principal.fromActor(this)))
    };

    public query({caller}) func get(key : Text) : async Result.Result<Asset, Text>{
        if (not isOwner(caller)) { return #err("you are not the owner of this Bucket") };
        #ok(map.get(key))
    };

    public shared({caller}) func change(key : Text, data : [Blob], sz : Nat, tp : FileExtension) : async Result.Result<Asset, Text>{
        if(not isOwner(caller)){ return #err("you are not the owner of this Bucket") };
        let oas = map.get(key);
        switch (oas.extension) {
            case (tp) { 
                let nas = asset(data, sz, tp);
                map.put(key, nas);
                return #ok(nas);
            };
            case _ { return #err("File type do not match") };
        };
    };

    public shared({caller}) func delete(key : Text) : async Result.Result<AssetExt, Text>{
        if(not isOwner(caller)){ return #err("you are not the owner of this Bucket") };
        map.delete(key);
        #ok(_asset(key, Principal.fromActor(this)))
    };

    public query({caller}) func wallet_receive() : async Result.Result<Nat, Text> {
        if (not isOwner(caller)) { return #err("you are not the owner of this Bucket") };
        let available = Cycles.available();
        let accepted = Cycles.accept(Nat.min(available, cycle_limit));
        #ok(accepted)
    };

    public shared({caller}) func addOwner(newOwner : Principal) : async Result.Result<Bool, Text>{
        if (not isOwner(caller)) { return #err("you are not the owner of this Bucket") }; 
        owners := TrieSet.put<Principal>(owners, newOwner, Principal.hash(newOwner), Principal.equal);
        #ok(true)
    };

    public shared(msg) func delOwner(o : Principal) : async Result.Result<Bool, Text>{
        if (not isOwner(caller)) { return #err("you are not the owner of this Bucket") };
        owners := TrieSet.delete<Principal>(owners, o, Principal.hash(o), Principal.equal);
        #ok(true)
    };

    //https://smartcontracts.org/docs/language-guide/upgrades.html
    system func preupgrade(){
        mapEntries := Iter.toArray(map.entries());
        ownersArray := TrieSet.toArray<Principal>(owners);
    };

    system func postupgrade(){
        type Asset = Types.Asset;

        map := HashMap.fromIter<Text, Asset>(mapEntries.vals(), 1, Text.equal, Text.hash);
        owners := TrieSet.fromArray<Principal>(ownersArray, Principal.hash, Principal.equal);

        mapEntries := [];
        ownersArray := [];
    };

};