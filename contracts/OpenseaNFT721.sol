pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./ERC2981.sol";

contract OpenseaNFT721 is ERC721Enumerable, ERC2981, Ownable, AccessControlEnumerable {
    string public contractURI;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(uint96 _royaltyFeesInBips, string memory _contractURI) ERC721("OpenseaNFT721", "ON2") {
        setRoyaltyInfo(owner(), _royaltyFeesInBips);
        contractURI = _contractURI;
    }

    modifier onlyAdmins {
        require(owner() == _msgSender() || hasRole(ADMIN_ROLE, _msgSender()), "Not allowed");
        _;
    }

    function addAdmin(address _newAdmin) public onlyOwner {
        require(getRoleMemberCount(ADMIN_ROLE) < 5, "Maximum limit");
        _grantRole(ADMIN_ROLE, _newAdmin);
    }

    function removeAdmin(address _targetAdmin) public onlyOwner {
        require(hasRole(ADMIN_ROLE, _targetAdmin), "Invalid admin");
        _revokeRole(ADMIN_ROLE, _targetAdmin);
    }

    function safeMint(address to, uint256 tokenId) public onlyAdmins {
        _safeMint(to, tokenId);
        if (to == owner()) {
            _setTokenRoyalty(tokenId, to, 0);
        } else {
            _setTokenRoyalty(tokenId, to, _getDefaultRoyalty().royaltyFraction);
        }
    }

    function burn(uint256 tokenId) public onlyAdmins {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }

    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyOwner {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
    }

    function setContractURI(string calldata _contractURI) public onlyOwner {
        contractURI = _contractURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return contractURI;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721Enumerable)
    {
        require(owner() == _msgSender() || hasRole(ADMIN_ROLE, _msgSender()), "Not allowed");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC2981, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}