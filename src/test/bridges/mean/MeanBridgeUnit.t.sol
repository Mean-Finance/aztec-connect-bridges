// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec.
pragma solidity >=0.8.4;

import {Test} from "forge-std/Test.sol";
import {AztecTypes} from "rollup-encoder/libraries/AztecTypes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MeanBridge} from "../../../bridges/mean/MeanBridge.sol";
import {ErrorLib} from "../../../bridges/base/ErrorLib.sol";
import {IDCAHub} from "../../../interfaces/mean/IDCAHub.sol";
import {ITransformerRegistry} from "../../../interfaces/mean/ITransformerRegistry.sol";

contract MeanBridgeUnitTest is Test {
    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public constant OWNER = 0x0000000000000000000000000000000000000001;
    IDCAHub public constant DCA_HUB = IDCAHub(0x0000000000000000000000000000000000000002);
    ITransformerRegistry public constant TRANSFORMER_REGISTRY = ITransformerRegistry(0x0000000000000000000000000000000000000003);

    AztecTypes.AztecAsset internal emptyAsset;

    address private rollupProcessor;
    MeanBridge private bridge;

    function setUp() public {
        // In unit tests we set address of rollupProcessor to the address of this test contract
        rollupProcessor = address(this);

        // Deploy a new example bridge
        bridge = new MeanBridge(DCA_HUB, TRANSFORMER_REGISTRY, OWNER, rollupProcessor);
        vm.label(address(bridge), "MEAN_BRIDGE");
        vm.deal(address(bridge), 0);

        // Some more labels
        vm.label(address(DAI), "DAI");
        vm.label(address(DCA_HUB), "DCA_HUB");
        vm.label(address(TRANSFORMER_REGISTRY), "TRANSFORMER_REGISTRY");
        vm.label(address(OWNER), "OWNER");
    }

    function testSetup() public {
        assertEq(address(bridge.DCA_HUB()), address(DCA_HUB));
        assertEq(address(bridge.TRANSFORMER_REGISTRY()), address(TRANSFORMER_REGISTRY));
        assertEq(bridge.owner(), OWNER);
    }

    function testMaxApprove() public {
        IERC20[] memory _tokens = new IERC20[](1);
        _tokens[0] = DAI;
        bridge.maxApprove(_tokens);
        assertEq(DAI.allowance(address(bridge), address(DCA_HUB)), type(uint256).max);
        assertEq(DAI.allowance(address(bridge), address(TRANSFORMER_REGISTRY)), type(uint256).max);
        assertEq(DAI.allowance(address(bridge), rollupProcessor), type(uint256).max);
    }

}

    
