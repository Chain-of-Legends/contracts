// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @custom:security-contact info@chainoflegends.com
contract ColNft is Initializable, ERC721Upgradeable, OwnableUpgradeable, ERC721EnumerableUpgradeable {
    string public version;

    enum genesisBoxType {
        COBALT,
        PYRITE,
        COPPER,
        GOLD
    }
    struct genesisBoxInfo {
        string name;
        uint256 price; // price in USD
        uint256 total;
        uint256 sold;
        string boxUri;
    }
    mapping(genesisBoxType => genesisBoxInfo) public boxInfos;

    uint256 boxId;
    uint256 public bnbPrice; // USD

    mapping(uint256 => string) private _tokenURIs;
    // https://forum.openzeppelin.com/t/function-settokenuri-in-erc721-is-gone-with-pragma-0-8-0/5978/3
    string private _baseURIextended;

    mapping(address => uint) public lastBoxPurchase;

    bool isCycle2Minted;

    //#region Duplicate defination overrides
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) 
      internal virtual override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721EnumerableUpgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    //#endregion

    function initialize() public initializer {
        boxId = 0;
        __Ownable_init();
        __ERC721_init("Chain of Legends NFT", "CLNFT");
        fillBoxesInfo();
        bnbPrice = 430;
    }

    function fillBoxesInfo() public onlyOwner{
      if(boxInfos[genesisBoxType.COBALT].sold == 0 && boxInfos[genesisBoxType.PYRITE].sold == 0 
            && boxInfos[genesisBoxType.COPPER].sold == 0 && boxInfos[genesisBoxType.GOLD].sold == 0){
        boxInfos[genesisBoxType.COBALT] = genesisBoxInfo("Cobalt box", 20, 250,0, 
            "https://bafybeibkaupdwmneofafho5zahnjbgm6zyt52pradamm4d3ygyuf7a33pi.ipfs.infura-ipfs.io/");
        boxInfos[genesisBoxType.PYRITE] = genesisBoxInfo("Pyrite box", 40, 150,0, 
            "https://bafybeieikt27cbzmnwg7lvh376wfyn663ssbackhx5qt2rh4ne42q2rhcu.ipfs.infura-ipfs.io/");
        boxInfos[genesisBoxType.COPPER] = genesisBoxInfo("Copper box", 72, 75,0, 
            "https://bafybeiht523ned5rl5sryikkld3y32lerodnlchymmkoojkelazsqbn6ua.ipfs.infura-ipfs.io/");
        boxInfos[genesisBoxType.GOLD] = genesisBoxInfo("Gold box", 270, 25,0, 
            "https://bafybeiaxpr7hq2as7bveqpx3syk4onvd2sonfi7bsdbhcrlsdn3cnmukv4.ipfs.infura-ipfs.io/");
      }
    }

    function fixBoxesAddresses() public{
      for (uint256 i = 1; i <= 25; i++) {
        _setTokenURI(i, "https://chainoflegends.com/assets/metadata/box-gold.json");
      }
      for (uint256 i = 26; i <= 100; i++) {
        _setTokenURI(i, "https://chainoflegends.com/assets/metadata/box-copper.json");
      }
      for (uint256 i = 101; i <= 250; i++) {
        _setTokenURI(i, "https://chainoflegends.com/assets/metadata/box-pyrite.json");
      }
      for (uint256 i = 251; i <= 500; i++) {
        _setTokenURI(i, "https://chainoflegends.com/assets/metadata/box-cobalt.json");
      }
    }

    //#region Token URI functions
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return Strings.toString(tokenId);
    }

    //#endregion

    function getBnbBoxPrice(genesisBoxType boxType) public view returns (uint256)
    {
      require(boxInfos[boxType].price > 0, "Invalid BoxType");
      return (boxInfos[boxType].price * 10**18) / bnbPrice;
    }

    function setBnbPrice(uint256 _bnbPrice) public onlyOwner {
        bnbPrice = _bnbPrice;
    }

    function mintGenesisBox(uint256 _boxId, string memory boxUrl)
        public
        onlyOwner
        returns (uint256)
    {
      boxId = _boxId;
      _safeMint(owner(), boxId);
      _setTokenURI(boxId, boxUrl);
      return boxId;
    }

    function mintGenesisBoxes(uint256 start, uint256 end)
        public
        onlyOwner
        returns (uint256)
    {
      //require(boxId < 715 , "Cycle 2 boxes alreary minted"); 
      require(start > 500 && start <= 715 && end >500 && end <= 715 && start <= end, "invalid numbers for start and end"); 
      string memory _box_url;
      for (uint256 i = start; i <= end; i++) {
        if(i > 500 && i <= 600)
          _box_url = "https://chainoflegends.com/assets/metadata/box-cobalt2.json";
          if(i > 600 && i <= 670)
          _box_url = "https://chainoflegends.com/assets/metadata/box-pyrite2.json";
          if(i > 670 && i <= 700)
          _box_url = "https://chainoflegends.com/assets/metadata/box-copper2.json";
          if(i > 700 && i <= 715)
          _box_url = "https://chainoflegends.com/assets/metadata/box-gold2.json";
        mintGenesisBox(i, _box_url);
      }

      return boxId;
    }

    // function mintGenesisBox(genesisBoxType boxType)
    //     public
    //     payable
    //     returns (uint256)
    // {
    //   genesisBoxInfo memory _boxInfo = boxInfos[boxType];
    //   bool validPurchase= canBuyBox(boxType, _boxInfo);
    //   require(validPurchase, "You can't buy box now");
    //   boxId = boxId + 1;
    //   _safeMint(msg.sender, boxId);
    //   _setTokenURI(boxId, _boxInfo.boxUri);
    //   boxInfos[boxType].sold++;
    //   lastBoxPurchase[msg.sender] = block.timestamp;
    //   address payable contract_owner = payable(owner());
    //   contract_owner.transfer(msg.value);
    //   return boxId;
    // }
    // function getCurrentSaleStage() public view returns (int){
    //   // uint goldBoxSaleStart = 1648582200; // Tue Mar 29 2022 19:30:00 GMT+0000
    //   // uint copperBoxSaleStart = 1648618200; // Wed Mar 30 2022 05:30:00 GMT+0000
    //   // uint pyriteBoxSaleStart = 1648661400; //	Wed Mar 30 2022 22:00:00 GMT+0430
    //   // uint cobaltBoxSaleStart = 1648711800; // Mar 31 2022 12:00:00 GMT+0430
    //   // uint saleEnd = 1648920600; // Apr 02 2022 22:00:00 GMT+0430
    //     uint goldBoxSaleStart = 1648728000; // 31 March 12:00 GMT
    //     uint copperBoxSaleStart = 1648814400; // 1 April 12:00 GMT
    //     uint pyriteBoxSaleStart = 1648900800; // 2 April 12:00 GMT
    //     uint cobaltBoxSaleStart = 1648987200; // 3 April 12:00 GMT
    //     uint saleEnd = 1649073600; // 4 April 12:00 GMT
        
    //     if( block.timestamp < goldBoxSaleStart)
    //         return -1;
    //     if( block.timestamp < copperBoxSaleStart)
    //         return 3;
    //     if( block.timestamp < pyriteBoxSaleStart)
    //         return 2;
    //     if( block.timestamp < cobaltBoxSaleStart)
    //         return 1;
    //     if( block.timestamp < saleEnd)
    //         return 0;
    //     return 4;
    // }
    // function canBuyBox(genesisBoxType boxType, genesisBoxInfo memory _boxInfo) private view returns (bool) {
    //   // uint goldBoxSaleStart = 1648582200; // Tue Mar 29 2022 19:30:00 GMT+0000
    //   // uint copperBoxSaleStart = 1648618200; // Wed Mar 30 2022 05:30:00 GMT+0000
    //   // uint pyriteBoxSaleStart = 1648661400; //	Wed Mar 30 2022 22:00:00 GMT+0430
    //   // uint cobaltBoxSaleStart = 1648711800; // Mar 31 2022 12:00:00 GMT+0430
    //   // uint saleEnd = 1648920600; // Apr 02 2022 22:00:00 GMT+0430
    //   // uint goldBoxSaleStart = 1648728000; // 31 March 12:00 GMT
    //   // uint copperBoxSaleStart = 1648814400; // 1 April 12:00 GMT
    //   // uint pyriteBoxSaleStart = 1648900800; // 2 April 12:00 GMT
    //   // uint cobaltBoxSaleStart = 1648987200; // 3 April 12:00 GMT
    //   // uint saleEnd = 1649073600; // 4 April 12:00 GMT
      
    //   // require(block.timestamp >= goldBoxSaleStart, "NFT Sale Not Started Yet");
    //   // require(block.timestamp <= saleEnd, "NFT Sale Ended");

    //   // if(boxType == genesisBoxType.GOLD)
    //   //   require(block.timestamp >= goldBoxSaleStart && block.timestamp < copperBoxSaleStart, 
    //   //     "Currently this boxtype sale is not started yet or ended");
    //   // if(boxType == genesisBoxType.COPPER)
    //   //   require(block.timestamp >= copperBoxSaleStart && block.timestamp < pyriteBoxSaleStart, 
    //   //     "Currently this boxtype sale is not started yet or ended");
    //   // if(boxType == genesisBoxType.PYRITE)
    //   //   require(block.timestamp >= pyriteBoxSaleStart && block.timestamp < cobaltBoxSaleStart , 
    //   //     "Currently this boxtype sale is not started yet or ended");
    //   // if(boxType == genesisBoxType.COBALT)
    //   //   require(block.timestamp >= cobaltBoxSaleStart && block.timestamp < saleEnd , 
    //   //     "Currently this boxtype sale is not started yet or ended");

    //   require(_boxInfo.price > 0, "there is no box with this type");
    //   require(_boxInfo.sold < _boxInfo.total, "This box SOLD OUT!");

    //   uint bnbBoxPrice = getBnbBoxPrice(boxType);
    //   require(msg.value >= bnbBoxPrice, "Not enough BNB");
    //   require(msg.value == bnbBoxPrice, "Invalid amount of BNB");

    //   //require(block.timestamp - lastBoxPurchase[msg.sender] >= 10 * 60, "You can purchase one box every 10 minutes.");

    //   return true;
    // }
}
