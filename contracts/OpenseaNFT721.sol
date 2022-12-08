pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./ERC2981.sol";

contract OpenseaNFT721 is ERC721Enumerable, ERC2981, Ownable, AccessControlEnumerable {
    using Counters for Counters.Counter;
    using Address for address;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    string public contractURI;
    string public illegalURI;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(uint96 _royaltyFeesInBips, string memory _contractURI, string memory _illegalURI) ERC721("OpenseaNFT721", "ON2") {
        _setDefaultRoyalty(address(0), _royaltyFeesInBips);
        contractURI = _contractURI;
        illegalURI = _illegalURI;
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

    function safeMint(address to, uint96 royalty) public onlyAdmins {
        _tokenIds.increment();
        _safeMint(to, _tokenIds.current());
        if (to == owner()) {
            _setTokenRoyalty(_tokenIds.current(), to, 0);
        } else {
            _setTokenRoyalty(_tokenIds.current(), to, royalty);
        }
    }

    function safeTransfer(
        address to,
        uint256 tokenId
    ) public onlyAdmins {
        _safeTransfer(_msgSender(), to, tokenId, "");
    }

    function safeTransfer(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public onlyAdmins {
        _safeTransfer(_msgSender(), to, tokenId, data);
    }

    function burn(uint256 tokenId) external onlyAdmins {
        _burn(tokenId);
    }

    function setContractURI(string calldata _contractURI) external onlyOwner {
        contractURI = _contractURI;
    }

    function setIllegalURI(string calldata _illegalURI) external onlyOwner {
        illegalURI = _illegalURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) {
            return illegalURI;
        }
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
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