/*

To trust a leader:
- Call              canTrust(address leader), get spot.
- Send transaction  trust(address leader, uint256 spot)

To untrust a leader:
- Call              canUntrust(address leader), get spot.
- Send transaction  untrust(uint256 spot)


*/

contract TrustDAO {
    mapping (address => mapping (uint256 => address)) public followers;
    mapping (address => uint256) public followersBalance;
    mapping (address => address) public trustedLeader;

    function trust(address leader, uint256 spot) {
        if (spot == 0) revert();
        if (trustedLeader[msg.sender] != 0x00 || trustedLeader[msg.sender] == leader) return;
        uint256 i=spot;
        while (followers[leader][spot] > 0x01) ++i;
        followers[leader][spot] = msg.sender;
        followersBalance[leader] += balanceOf(msg.sender);
        trustedLeader[msg.sender] = leader;
    }
    function untrust(uint256 spot) {
        if (spot == 0) revert();
        address leader = trustedLeader[msg.sender];
        if (followers[leader][spot] == msg.sender) followers[leader][spot] = 0x01;
        followersBalance[leader] -= balanceOf(msg.sender);
        trustedLeader[msg.sender] = 0x00;
    }

// Constant methods

    function trustedBalanceOf(address leader) constant public returns (uint256) {
        uint256 b;
        if (trustedLeader[leader] == 0x00) {
          b = balanceOf(leader);
        } else b = 0;
        return b + followersBalance[leader];
    }

    // Returns 0 if already trusted, return spot otherwise
    function canTrust(address leader) constant public returns (uint256 spot) {
        uint256 i=1;
        while (followers[leader][i] > 0x01) {
            if (followers[leader][i] == msg.sender) return 0;
            ++i;
        }
        return i;
    }

    // Returns spot if already untrusted, return 0 otherwise
    function canUntrust(address leader) constant public returns (uint256 spot) {
        uint256 i=1;
        while (followers[leader][i] > 0x01) {
            if (followers[leader][i] == msg.sender) return i;
            ++i;
        }
        return 0;
    }


// ERC20

event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    address admin;
    uint256 constant MAX_UINT256 = 2**256 - 1;
    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 totalSupply;
    function TrustDAO() public {
        admin = msg.sender;
        balances[msg.sender] = 1000000;
        totalSupply = 1000000;
        name = "TOKEN1";
        decimals = 18;
        symbol = "TN1";
    }

    // Unable to transfer if has trustedLeader
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (trustedLeader[msg.sender] != 0x00) return false;
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (trustedLeader[msg.sender] != 0x00) return false;
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender)
    constant public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    function mint(uint256 _value, address _to) {
        if (msg.sender != admin) return;
        balances[_to] += _value;
        totalSupply += _value;
    }
}
