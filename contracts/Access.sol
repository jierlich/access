// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Access
 * @dev Check if a user has access to a non-crypto digital asset
 *      Ex. Article paywall
 */
contract Access {

    uint256 counter;

    // asset -> wallet -> hasAccess
    mapping(uint256 => mapping(address => bool)) addressWithAccess;
    mapping(uint256 => uint256) feeAmount;
    mapping(uint256 => uint) pendingWithdrawals;
    mapping(uint256 => address) owners;

    modifier onlyAssetOwner (uint256 _id) {
        require(owners[_id] == msg.sender, "Only the asset owner can call this function");
        _;
    }
    
    event AssetCreated(uint256 indexed _id, address _owner);

    function create(uint256 _fee, address _owner) public returns (uint256) {
        counter += 1;
        feeAmount[counter] = _fee;
        owners[counter] = _owner;
        emit AssetCreated(counter, _owner);
        return counter;
    }
    
    function grantAccess(uint256 _id, address _addr) public payable {
        require(msg.value == feeAmount[_id], 'Incorrect fee amount');
        pendingWithdrawals[_id] += msg.value;
        addressWithAccess[_id][_addr] = true;
    }
    
    function checkAccess(uint256 _id, address _addr) public view returns (bool){
        return addressWithAccess[_id][_addr];
    }
    
    function withdraw (uint256 _id) onlyAssetOwner(_id) public {
        address payable assetOwner = payable(msg.sender);
        pendingWithdrawals[_id] = 0;
        assetOwner.transfer(pendingWithdrawals[_id]);
    }
}