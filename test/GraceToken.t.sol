// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {MerkleAirdrop} from "../src/GraceToken.sol";

contract GraceTest is Test {
    using stdJson for string;
    MerkleAirdrop public merkleAirdrop;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint amount;
        uint tokenId;
    }
    Result public result;
    User public user;
    bytes32 root =
        0x015f4e164eb9b2eee75aa4768771402446db05927e76d128e58acaf7f2e4573c;
    address user1 = 0x37D93e2358B619A8808Ecb7A9169B73CE908d0EA;

    function setUp() public {
        merkleAirdrop = new MerkleAirdrop(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_airdrop_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_erc1155_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".address")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".amount")
        );

        user.tokenId = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".tokenId")
        );

        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = merkleAirdrop.claim(user.user, user.amount, user.tokenId, result.proof);
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        merkleAirdrop.claim(user.user,  user.amount, user.tokenId, result.proof);
        vm.expectRevert("already claimed");
        merkleAirdrop.claim(user.user, user.amount,  user.tokenId, result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        merkleAirdrop.claim(user.user, user.tokenId, user.amount, fakeProofleaveitleaveit);
    }
}
