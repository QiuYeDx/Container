import Container "Container";
import Principal "mo:base/Principal";
actor testContainer{
    public shared({caller}) func test() : async Nat{
        let container = await Container.Container(caller);
        await container.test()
    }
}