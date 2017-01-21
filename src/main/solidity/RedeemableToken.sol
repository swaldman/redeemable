contract RedeemableToken {

  /*
   * Fields
   */
  
  address public issuer;

  uint256 public totalSupply;

  mapping (address => uint256) public uncommittedBalances;
  mapping (address => uint256) public redemptionRequests;

  /*
   * Constructor
   */

  function RedeemableToken() {
    issuer = msg.sender;
  }

  /*
   * Functions
   */

  function balances( address holder ) constant returns (uint256 balance) {
    return (uncommittedBalances[holder] + redemptionRequests[holder]);
  }

  function issue( address recipient, uint256 amount, string message ) onlyIssuer {
    uncommittedBalances[recipient] += amount;
    totalSupply += amount;

    Issuance( recipient, amount, message );
  }

  function transfer( address recipient, uint256 amount ) notIssuer {
    if ( recipient == issuer ) throw;
    if (uncommittedBalances[msg.sender] < amount) throw;

    uncommittedBalances[msg.sender] -= amount;
    uncommittedBalances[recipient] += amount;
  }

  function requestRedemption( uint256 amount, string message ) notIssuer {
    if (uncommittedBalances[msg.sender] < amount) throw;
    if (redemptionRequests[msg.sender] > 0) throw;

    uncommittedBalances[msg.sender] -= amount;
    redemptionRequests[msg.sender] += amount;

    RedemptionRequest( msg.sender, amount, message );
  }

  function cancelRedemption( string message ) notIssuer {
    uncommittedBalances[msg.sender] += redemptionRequests[msg.sender];
    redemptionRequests[msg.sender] = 0;

    RedemptionCanceled( msg.sender, message );
  }

  function redeem( address redeemer, string message ) onlyIssuer {
    uint256 redeemable = redemptionRequests[redeemer];
    if ( redeemable > 0 ) {
      redemptionRequests[redeemer] -= redeemable;
      totalSupply -= redeemable;

      Redemption( redeemer, redeemable, message );
    }
  }

  function () {
    throw;
  }

  /*
   *  Modifiers
   */

  modifier onlyIssuer {
    if ( msg.sender != issuer ) throw;
    _;
  }

  modifier notIssuer {
    if ( msg.sender == issuer ) throw;
    _;
  }

  /*
   *  Events
   */

  event Issuance(address indexed recipient, uint amount, string message);
  event RedemptionRequest(address indexed redeemer, uint amount, string message);
  event RedemptionCanceled(address indexed redeemer, string message);
  event Redemption(address indexed redeemer, uint amount, string message);
}
