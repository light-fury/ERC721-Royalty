pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC2981.sol";

contract OpenseaNFT721 is ERC721, ERC721Enumerable, ERC2981, Ownable {
    string public contractURI;

    constructor(uint96 _royaltyFeesInBips, string memory _contractURI) ERC721("OpenseaNFT721", "ON2") {
        setRoyaltyInfo(owner(), _royaltyFeesInBips);
        contractURI = _contractURI;
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
        if (to == owner()) {
            _setTokenRoyalty(tokenId, to, 0);
        } else {
            _setTokenRoyalty(tokenId, to, _getDefaultRoyalty().royaltyFraction);
        }
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
    ) internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}