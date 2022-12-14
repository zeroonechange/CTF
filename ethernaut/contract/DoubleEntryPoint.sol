// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
 
    function owner() public view virtual returns (address) {
        return _owner;
    }
 
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
 
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
 
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
  
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface DelegateERC20 {
  function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
    function raiseAlert(address user) external;
}

contract Forta is IForta {
  mapping(address => IDetectionBot) public usersDetectionBots;
  mapping(address => uint256) public botRaisedAlerts;

  function setDetectionBot(address detectionBotAddress) external override {
      usersDetectionBots[msg.sender] = IDetectionBot(detectionBotAddress);
  }

  function notify(address user, bytes calldata msgData) external override {
    if(address(usersDetectionBots[user]) == address(0)) return;
    try usersDetectionBots[user].handleTransaction(user, msgData) {
        return;
    } catch {}
  }

  function raiseAlert(address user) external override {
      if(address(usersDetectionBots[user]) != msg.sender) return;
      botRaisedAlerts[msg.sender] += 1;
  } 
}

contract CryptoVault {
    address public sweptTokensRecipient;
    IERC20 public underlying;

    constructor(address recipient) {
        sweptTokensRecipient = recipient;
    }

    function setUnderlying(address latestToken) public {
        require(address(underlying) == address(0), "Already set");
        underlying = IERC20(latestToken);
    }

 
   // retrieve tokens stuck in contract   ??? token ????????????????????? sweptTokensRecipient
   // underlying ?????? DoubleEntryPoint ?????????  ???????????????100??? ??? token
   // ?????? ??????????????? 100??? LegacyToken 
   // ???????????? ??????bug ?????????  token??????????????????
    function sweepToken(IERC20 token) public {
        require(token != underlying, "Can't transfer underlying token");
        token.transfer(sweptTokensRecipient, token.balanceOf(address(this)));
    }
    
}

contract LegacyToken is ERC20("LegacyToken", "LGT"), Ownable {
    DelegateERC20 public delegate;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function delegateToNewContract(DelegateERC20 newContract) public onlyOwner {
        delegate = newContract;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        if (address(delegate) == address(0)) {
            return super.transfer(to, value);
        } else {
            return delegate.delegateTransfer(to, value, msg.sender);
        }
    }
}

// Forta : ????????????????????? detection bot ??????  -  ?????????????????????????????????????????? ????????????
// my job: ???????????? detection bot ?????? Forta ???????????????  - ??????bot???????????? ????????????????????????bug???????????????????????????
contract DoubleEntryPoint is ERC20("DoubleEntryPointToken", "DET"), DelegateERC20, Ownable {
    address public cryptoVault;
    address public player;
    address public delegatedFrom;
    Forta public forta;

    constructor(address legacyToken, address vaultAddress, address fortaAddress, address playerAddress) {
        delegatedFrom = legacyToken;
        forta = Forta(fortaAddress);
        player = playerAddress;
        cryptoVault = vaultAddress;
        _mint(cryptoVault, 100 ether);
    }

    modifier onlyDelegateFrom() {
        require(msg.sender == delegatedFrom, "Not legacy contract");
        _;
    }

    modifier fortaNotify() {
        address detectionBot = address(forta.usersDetectionBots(player));

        // Cache old number of bot alerts
        uint256 previousValue = forta.botRaisedAlerts(detectionBot);

        // Notify Forta
        forta.notify(player, msg.data);

        // Continue execution
        _;

        // Check if alarms have been raised
        if(forta.botRaisedAlerts(detectionBot) > previousValue) revert("Alert has been triggered, reverting");
    }

    function delegateTransfer(
        address to,
        uint256 value,
        address origSender
    ) public override onlyDelegateFrom fortaNotify returns (bool) {
        _transfer(origSender, to, value);
        return true;
    }
}

contract MyBot is IDetectionBot{

    IForta forta; 
    address cryptoVault; 
    constructor(address _addr, address _addr2) {
        forta = IForta(_addr);
        cryptoVault = _addr2;
    }

    function handleTransaction(address user, bytes calldata msgData) external{
        address addr;
        uint256 value;
        address originSender; 
        (addr, value, originSender) = abi.decode(msgData[4:], (address, uint256, address));
        if(originSender == cryptoVault){  
            forta.raiseAlert(user);
        }
    }
}

/**
????????????
	The desired behavior of CryptoVault is that it can sweep any token except the underlying DET token. 
	But the problem is we can sweep DET indirectly by sweeping LegacyToken. 
	LegacyToken???s transfer() function calls DET???s delegateTransfer(). 
	If you look at the source code you???ll see this simply transfers DET. 
	Therefore we can drain the vault of DET by calling sweepToken(<LegacyToken Address>).
	CryptoVault ???????????????token   LGT ??? DET  ??????100???  ?????? DET ??????????????????  ???LGT ????????????  
	??????bug ??????????????? LGT ????????? delegate ??? DET ????????????   ????????????????????????
	
	
	DelegateERC20      --????????????
		delegateTransfer(address to, uint256 value, address origSender)
	
	IDetectionBot      --???????????????  ?????????????????????   ?????????user???msgData????????????????????????????????????????????????
		handleTransaction(address user, bytes calldata msgData)
	
	IForta            --????????????????????? ??????      ??????????????????????????????
		setDetectionBot(address detectionBotAddress)
		notify(address user, bytes calldata msgData)
		raiseAlert(address user) 
	
	contract Forta is IForta   --?????????????????????????????????
		mapping(address => IDetectionBot) public usersDetectionBots;
		mapping(address => uint256) public botRaisedAlerts;
			setDetectionBot(address detectionBotAddress)
			notify(address user, bytes calldata msgData)
			raiseAlert(address user)
			
	contract CryptoVault 	  --????????????  ?????? LGT ??? DET 100 ???     ?????? CryptoVault????????? DET ?????????
		address public sweptTokensRecipient;  -- ????????????????????????????????? token
		IERC20 public underlying;    -- ???????????????????????? token
			setUnderlying(address latestToken)
			sweepToken(IERC20 token)
			
	contract LegacyToken is ERC20("LegacyToken", "LGT"), Ownable	--LGT  ?????????????????? DEP   
		DelegateERC20 public delegate;
			mint(address to, uint256 amount)
			delegateToNewContract(DelegateERC20 newContract)
			transfer(address to, uint256 value)
	
	contract DoubleEntryPoint is ERC20("DoubleEntryPointToken", "DET"), DelegateERC20, Ownable   --DEP  ?????? CryptoVault????????? DET ?????????
		    address public cryptoVault;
			address public player;
			address public delegatedFrom;
			Forta public forta;
				delegateTransfer(address to,uint256 value,address origSender)
	
	???????????????????????????
	await contract.cryptoVault();
	'0xac8eC7d8904c29CE1B995DB1a6016C5a237D24B5'
	await contract.player();
	'0x0Dd01A495A499e642a0B7d45CCa54522034fBa2C'
	await contract.delegatedFrom();
	'0x9D93fD74137a26ad1032ef59cc8b908dC4CC1B9d'
	await contract.forta();
	'0xacD72db6a2ECa7a8A459469c48170fbFeEA410Ca'
	?????????????????????
	contract MyBot is IDetectionBot{

		IForta forta; 
		address cryptoVault; 
		constructor(address _addr, address _addr2) {
			forta = IForta(_addr);
			cryptoVault = _addr2;
		}

		function handleTransaction(address user, bytes calldata msgData) external override{
			address addr;
			uint256 value;
			address originSender; 
			(addr, value, originSender) = abi.decode(msgData[4:], (address, uint256, address));
			if(originSender == cryptoVault){
				forta.raiseAlert(user);
			}
		}
	}
	?????? forta ????????? setDetectionBot(0x6A38Bb78E7766CbB99F7119a623dd3a81Dc48C53)  
	??????   ??????  
 */