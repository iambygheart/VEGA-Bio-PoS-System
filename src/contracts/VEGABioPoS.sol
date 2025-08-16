// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title VEGABioPoS
 * @dev Biometric Proof-of-Stake smart contract with consciousness validation
 */
contract VEGABioPoS is ReentrancyGuard, Ownable, Pausable {
    
    struct BiometricData {
        bytes32 eegHash;
        uint256 timestamp;
        uint256 validationScore;
        bool isValid;
    }
    
    struct Validator {
        address validatorAddress;
        uint256 stake;
        uint256 reputation;
        bool isActive;
        BiometricData lastValidation;
    }
    
    mapping(address => Validator) public validators;
    mapping(bytes32 => bool) public usedBiometricHashes;
    
    uint256 public constant MIN_STAKE = 1000 * 10**18; // 1000 tokens
    uint256 public constant MIN_VALIDATION_SCORE = 75; // 75% threshold
    uint256 public totalStaked;
    
    event ValidatorRegistered(address indexed validator, uint256 stake);
    event BiometricValidated(address indexed validator, bytes32 eegHash, uint256 score);
    event RewardDistributed(address indexed validator, uint256 amount);
    
    constructor() {}
    
    /**
     * @dev Register as a validator with biometric data
     */
    function registerValidator(bytes32 _eegHash, uint256 _validationScore) 
        external 
        payable 
        nonReentrant 
        whenNotPaused 
    {
        require(msg.value >= MIN_STAKE, "Insufficient stake");
        require(_validationScore >= MIN_VALIDATION_SCORE, "Validation score too low");
        require(!usedBiometricHashes[_eegHash], "Biometric data already used");
        require(!validators[msg.sender].isActive, "Already registered");
        
        validators[msg.sender] = Validator({
            validatorAddress: msg.sender,
            stake: msg.value,
            reputation: 100,
            isActive: true,
            lastValidation: BiometricData({
                eegHash: _eegHash,
                timestamp: block.timestamp,
                validationScore: _validationScore,
                isValid: true
            })
        });
        
        usedBiometricHashes[_eegHash] = true;
        totalStaked += msg.value;
        
        emit ValidatorRegistered(msg.sender, msg.value);
        emit BiometricValidated(msg.sender, _eegHash, _validationScore);
    }
    
    /**
     * @dev Validate new biometric data for existing validator
     */
    function validateBiometric(bytes32 _eegHash, uint256 _validationScore) 
        external 
        nonReentrant 
        whenNotPaused 
    {
        require(validators[msg.sender].isActive, "Not an active validator");
        require(_validationScore >= MIN_VALIDATION_SCORE, "Validation score too low");
        require(!usedBiometricHashes[_eegHash], "Biometric data already used");
        
        validators[msg.sender].lastValidation = BiometricData({
            eegHash: _eegHash,
            timestamp: block.timestamp,
            validationScore: _validationScore,
            isValid: true
        });
        
        usedBiometricHashes[_eegHash] = true;
        
        // Increase reputation for successful validation
        if (validators[msg.sender].reputation < 1000) {
            validators[msg.sender].reputation += 1;
        }
        
        emit BiometricValidated(msg.sender, _eegHash, _validationScore);
    }
    
    /**
     * @dev Get validator information
     */
    function getValidator(address _validator) 
        external 
        view 
        returns (
            uint256 stake,
            uint256 reputation,
            bool isActive,
            bytes32 lastEegHash,
            uint256 lastValidationTime,
            uint256 lastValidationScore
        ) 
    {
        Validator memory validator = validators[_validator];
        return (
            validator.stake,
            validator.reputation,
            validator.isActive,
            validator.lastValidation.eegHash,
            validator.lastValidation.timestamp,
            validator.lastValidation.validationScore
        );
    }
    
    /**
     * @dev Emergency pause function
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause function
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}