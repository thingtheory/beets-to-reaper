// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "solidity-interfaces/beethovenx/IBeetsBar.sol";
import "solidity-interfaces/beethovenx/IBalancerVault.sol";
import "./interfaces/reaper/ICrypt.sol";

contract BeetsToReaper is Ownable {
  ICrypt         public immutable crypt;
  IBalancerVault public immutable balancerVault;
  IBeetsBar      public immutable beetsBar;
  IERC20         public immutable beets;
  IERC20         public immutable wftm;
  IERC20         public immutable fBeetsBPT;
  bytes32        public immutable fBeetsPoolID;

  uint256   public fee = 0; // fee in BPS
  address   public feeReceiver;
  address[] public lpTokens;

  mapping(address=>bool) public feeExempt;

  event SetFee(address indexed _feeReceiver, uint256 _fee);
  event SetFeeExempt(address indexed _caller, bool _exempt);

  constructor(address _crypt, address _vault, address _beetsBar, address _beets, address _wftm, address _fBeetsBPT, bytes32 _fBeetsPoolID) {
    crypt = ICrypt(_crypt);
    balancerVault = IBalancerVault(_vault);
    beetsBar = IBeetsBar(_beetsBar);
    beets = IERC20(_beets);
    wftm = IERC20(_wftm);
    fBeetsBPT = IERC20(_fBeetsBPT);
    lpTokens.push(_wftm);
    lpTokens.push(_beets);
    fBeetsPoolID = _fBeetsPoolID;

    IERC20(_beets).approve(_vault, type(uint256).max);
    IERC20(_fBeetsBPT).approve(_beetsBar, type(uint256).max);
    IERC20(_beetsBar).approve(_crypt, type(uint256).max);
  }

  function destroy() external onlyOwner {
    selfdestruct(payable(owner()));
  }

  function recover(address _token) external onlyOwner {
    IERC20(_token).transfer(
      owner(),
      IERC20(_token).balanceOf(address(this))
    );
  }

  function setFee(uint256 _fee, address _feeReceiver) external onlyOwner {
    if (_fee != 0) {
      require(_feeReceiver != address(0), "zero receiver");
    }

    require(_fee <= 500, "fee limit"); // 5%
    fee = _fee;
    feeReceiver = _feeReceiver;

    emit SetFee(_feeReceiver, _fee);
  }

  function setFeeExempt(bool _exempt, address _caller) external onlyOwner {
    feeExempt[_caller] = _exempt;

    emit SetFeeExempt(_caller, _exempt);
  }

  function zapAll(uint256 _minimumReceived) external {
    zap(beets.balanceOf(msg.sender), _minimumReceived);
  }

  function zap(uint256 _amount, uint256 _minimumReceived) public {
    uint256 received = zapToBeets(_amount, _minimumReceived);

    crypt.deposit(received);
    crypt.transfer(msg.sender, crypt.balanceOf(address(this)));
  }

  function zapToBeets(uint256 _amount, uint256 _minimumReceived) public returns(uint256){
    uint256 balBefore = beetsBar.balanceOf(address(this));
    beets.transferFrom(msg.sender, address(this), _amount);

    if (fee > 0 && feeReceiver != address(0)) {
      uint256 feeTaken = (_amount * fee);
      beets.transfer(feeReceiver, feeTaken / 1e4);
      _amount = _amount - feeTaken;
    }


    convertToFreshBeets(_amount);
    uint256 received = beetsBar.balanceOf(address(this)) - balBefore;
    require(received >= _minimumReceived, "minimum received");

    return received;
  }

  function convertToFreshBeets(uint256 beetsAmt) internal {
    balancerJoin(fBeetsPoolID, address(beets), beetsAmt);
    uint256 amount = fBeetsBPT.balanceOf(address(this));

    beetsBar.enter(amount);
  }

  function balancerJoin(bytes32 _poolId, address _tokenIn, uint256 _amountIn) internal {
    uint256[] memory amounts = new uint256[](lpTokens.length);
    for (uint256 i = 0; i < amounts.length; i++) {
        amounts[i] = lpTokens[i] == _tokenIn ? _amountIn : 0;
    }
    bytes memory userData = abi.encode(1, amounts, 1); // TODO

    IBalancerVault.JoinPoolRequest memory request = IBalancerVault.JoinPoolRequest(lpTokens, amounts, userData, false);
    balancerVault.joinPool(_poolId, address(this), address(this), request);
  }
}
