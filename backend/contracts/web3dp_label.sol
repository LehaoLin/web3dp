// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Web3DPLabel{
    struct Label {
        uint256 label_id;
        address user;
        string label;
        uint256 status;
        uint256 token_id;
    }

    // tokenID => Label[]
    mapping(uint256 => Label[]) public label_map;
    
    function addLabel(string memory label, uint256 token_id) public {
        Label memory newLabel = Label(label_map[token_id].length+1, msg.sender, label, 1, token_id);
        label_map[token_id].push(newLabel);
    }

    function removeLabel(string memory label, uint256 token_id) public {
        Label memory newLabel = Label(label_map[token_id].length+1, msg.sender, label, 0, token_id);
        label_map[token_id].push(newLabel);
    }

    function getLabels(uint256 token_id) public view returns (Label[] memory) {
        return label_map[token_id];
    }

    function getLabel(uint256 token_id, uint256 label_id) public view returns (string memory) {
        return label_map[token_id][label_id-1].label;
    }

    function getLabelUser(uint256 token_id, uint256 label_id) public view returns (address) {
        return label_map[token_id][label_id-1].user;
    }

    function getLabelStatus(uint256 token_id, uint256 label_id) public view returns (uint256) {
        return label_map[token_id][label_id-1].status;
    }
}