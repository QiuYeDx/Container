import Cycles "mo:base/ExperimentalCycles";
import TrieSet "mo:base/TrieSet";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Types "/Module/Types";
//import Bucket "/Storage/Bucket";

// 1. update bucket's canister : bucket's controller 必须包括container's controller
// 2. 生成bucket
// 3. 获取bucket info : 所有的bucket info
// 4. 增删改查 container owners 

shared({caller}) actor class Container(owner_ : Principal) = this{
    // trie set : owners 
    // only owners can add owner
    
    private type BucketInfo = {
        //bucket : Bucket.Bucket;
        avalMemory : Nat;
    };
    private type BucketIndex = {
        key : Text;
        bucket_id : Principal;
    };

    private var kvMap = TrieMap.TrieMap<Blob, Principal>(Blob.equal, Blob.hash);
    private var bucketMap = TrieMap.TrieMap<Principal, BucketInfo>(Principal.equal, Principal.hash);
    private stable var owners = TrieSet.empty<Principal>();
    public func test() : async Nat{
        0
    }
};