let vue = new Vue({
	el: "#vue-app",
	data() {
		return {
			connected: false,
			ethers: null,
			signer: null,
			account: null,
			ERC20: null,
			stakeYourName: null,
			stakeYourNameAddress: "0x2487977f47Fb9395c70889141dd42C062517f17A",
			investmentManager: null,
			investmentManagerAddress:"0x37A0DC769fb0E3250ff9Dd5D55A757d8Aad97A73",
			nameManager: null,
			nameManagerAddress: "0x4Ae11e66cbd96245630cD0CeB4098Ade3AA4D2a7",
			DAI_Contract: "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
			USDC_Contract: "0xe22da380ee6B445bb8273C81944ADEB6E8450422",
			TUSD_Contract: "0x016750AC630F711882812f24Dba6c95b9D35856d",
			UNISWAP_Contract: "0x075A36BA8846C6B6F53644fDd3bf17E5151789DC",
			USDT_Contract: "0x13512979ADE267AB5100878E2e0f485B568328a4",
			AAVE_Contract: "0xB597cd8D3217ea6477232F9217fa70837ff667Af",
			contractOwner: null,
			userVault: null,
			curve: null,
			curveAddress: "0x3d2623C0Cdd2ba942a30FED3C92902091FE0D9c1",
			collateralToken: "0x95b58a6bff3d14b7db2f5cb5f0ad413dc2940658",
			createdTokenAddress: null,
			txPending: false,
			txComplete: false,
			depositToken: "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
			depositAmount: null,
			approvalRequired: true,
			approvalAmount: null,
			nameValid: false,
			repeatUser: false,
			ENS_Name: null,
			ENS_address: null,
			ENS_Domain: "eth",
			name_Expiry: null,
			network: null,
			networkWarning: null,
			assetAmount1: null,
			assetAmount2: null,
			assetAmount3: null,
			assetAmount4: null,
			assetToken1: "",
			assetToken2: "",
			assetToken3: "",
			assetToken4: "",
			asset1: null,
			asset2: null,
			asset3: null,
			asset4: null,
			name1: null,
			name2: null,
			name3: null,
			name4: null,
			readableName1: null,
			readableName2: null,
			readableName3: null,
			readableName4: null,
			nameExpiry1: null,
			nameExpiry2: null,
			nameExpiry3: null,
			nameExpiry4: null,
			vault: null,
			stakeYourNameABI: [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"referralCode","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"},{"inputs":[{"internalType":"string[]","name":"_name","type":"string[]"}],"name":"addName","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string[][]","name":"_names","type":"string[][]"}],"name":"addMultipleNames","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_name","type":"uint256"}],"name":"removeName","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"_names","type":"uint256[]"}],"name":"removeMultipleNames","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"deposit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"deployVault","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_vault","type":"address"}],"name":"setMasterVault","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"uint256","name":"_balance","type":"uint256"}],"name":"setBalance","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_vault","type":"address"}],"name":"findVault","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"approveVault","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"vaultAddAsset","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"vaultRemoveAsset","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getOwner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_user","type":"address"}],"name":"renewNames","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renewNamesGroupingUsers","outputs":[],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"_users","type":"address[]"}],"name":"countRenewals","outputs":[{"internalType":"uint256","name":"_count","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"swapAssets","outputs":[],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_ref","type":"uint256"}],"name":"updateReferral","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"_address","type":"address"}],"name":"setNameManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"_address","type":"address"}],"name":"setExchangeManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_address","type":"address"}],"name":"setInvestmentManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"approveInvestmentManager","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"_nameManager","type":"address"},{"internalType":"address payable","name":"_exchangeManager","type":"address"},{"internalType":"address","name":"_investmentManager","type":"address"},{"internalType":"address","name":"_vault","type":"address"},{"internalType":"address payable","name":"_oneSplit","type":"address"},{"internalType":"address","name":"_ens","type":"address"}],"name":"setupTestNet","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"retrieveETH","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_vault","type":"address"}],"name":"emptyVault","outputs":[],"stateMutability":"nonpayable","type":"function"}],
			nameManager_ABI: [{"inputs":[{"internalType":"uint256","name":"_networkID","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"},{"inputs":[{"internalType":"string[]","name":"_names","type":"string[]"},{"internalType":"uint256","name":"_duration","type":"uint256"}],"name":"executeBulkRenewal","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"string[]","name":"_names","type":"string[]"},{"internalType":"uint256","name":"_duration","type":"uint256"}],"name":"checkBulkPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_name","type":"string"},{"internalType":"uint256","name":"_duration","type":"uint256"}],"name":"checkPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"_ints","type":"uint256[]"}],"name":"uintArrayToStringsArray","outputs":[{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"_nameList","type":"uint256[]"}],"name":"checkForRenewals","outputs":[{"internalType":"uint256[]","name":"","type":"uint256[]"},{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"_nameList","type":"uint256[]"}],"name":"countRenewals","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string[]","name":"_name","type":"string[]"}],"name":"returnHash","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"string[]","name":"_name","type":"string[]"}],"name":"resolveName","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_labelhash","type":"uint256"}],"name":"renewalDue","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_time","type":"uint256"}],"name":"updateRenewalPeriod","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_address","type":"address"}],"name":"updateRegistrar","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_address","type":"address"}],"name":"updateBulkRenewal","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_name","type":"uint256"}],"name":"getNameExpiry","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"returnEnsAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"returnEnsRegAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"returnBulkRenewalAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"checkRegistryMatches","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"_bytes","type":"bytes32"}],"name":"convertBytesToUint","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"_uint","type":"uint256"}],"name":"convertUintToBytes","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"string","name":"_subdomain","type":"string"},{"internalType":"bytes32","name":"_name","type":"bytes32"}],"name":"computeHash","outputs":[{"internalType":"bytes32","name":"namehash","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"retrieveETH","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_ens","type":"address"}],"name":"updateAddresses","outputs":[],"stateMutability":"nonpayable","type":"function"}],
			IERC20_ABI: [{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}],
			UserVault_ABI: [{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"assets","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"balance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"names","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"readableName","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"stateMutability":"payable","type":"receive"},{"inputs":[],"name":"collectETH","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"uint256","name":"_balance","type":"uint256"}],"name":"setBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_name","type":"uint256"},{"internalType":"string[]","name":"_readableName","type":"string[]"}],"name":"addName","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"_names","type":"uint256[]"},{"internalType":"string[][]","name":"_readableNames","type":"string[][]"}],"name":"addMultipleNames","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_name","type":"uint256"}],"name":"removeName","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256[]","name":"_names","type":"uint256[]"}],"name":"removeMultipleNames","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"addAsset","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"removeAsset","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"countAssets","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"countNames","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"readNames","outputs":[{"internalType":"uint256[]","name":"","type":"uint256[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_hash","type":"uint256"},{"internalType":"uint256","name":"_index","type":"uint256"}],"name":"readSubName","outputs":[{"internalType":"string","name":"_name","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_index","type":"uint256"}],"name":"assembleName","outputs":[{"internalType":"string","name":"_name","type":"string"}],"stateMutability":"view","type":"function"}],
			InvestmentManager_ABI: [{"inputs":[{"internalType":"uint256","name":"_networkID","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"_address","type":"address"},{"indexed":false,"internalType":"uint256","name":"state","type":"uint256"}],"name":"debug","type":"event"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"aTokens","outputs":[{"internalType":"string","name":"symbol","type":"string"},{"internalType":"address","name":"tokenAddress","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"address","name":"_userVault","type":"address"}],"name":"approveLendingPool","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"getAToken","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"address","name":"_userVault","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"deposit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"}],"name":"checkAllowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"},{"internalType":"address","name":"_user","type":"address"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"address","name":"_vault","type":"address"}],"name":"getBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"address","name":"_vault","type":"address"}],"name":"getInterest","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_asset","type":"address"},{"internalType":"address","name":"_vault","type":"address"}],"name":"getTotal","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"retrieveETH","outputs":[],"stateMutability":"nonpayable","type":"function"}]
		};
	},
	watch: {
	    depositToken: function() {
	        this.checkApproval();
	    },   
	    ENS_Name: function() {
	        this.checkName();
	    },
	    depositAmount: function() {
	        this.checkName();
	    },
	    asset1: function() {
	        this.updateAsset1();
	    },
	    asset2: function() {
	        this.updateAsset2();
	    },
	    asset3: function() {
	        this.updateAsset3();
	    }
	},
	methods: {
		async connect() {
			if (window.ethereum) {
				this.ethers = new ethers.providers.Web3Provider(window.ethereum)
				this.signer = this.ethers.getSigner()
				window.ethereum.request({ method: 'eth_requestAccounts' });
				//window.ethereum.enable();
				this.network = await this.ethers.getNetwork();
				this.connected = true;
				this.initApp()
			} else {
				alert(
					"To use this app you'll need metamask or another web3 provider.'"
				);
			}
		},
		async initApp() {
			this.account = await this.signer.getAddress()
			userAddress.userAddress = this.account
			this.stakeYourName = new ethers.Contract(
				this.stakeYourNameAddress,
				this.stakeYourNameABI,
				this.signer
			);
            this.findVault();
		},
		async checkApproval(){
			this.ERC20 = new ethers.Contract(
				this.depositToken,
				this.IERC20_ABI,
				this.signer
			);
			this.approvalAmount = await this.ERC20.allowance(
			    this.account,
			    this.stakeYourNameAddress
	        );
	        if (this.approvalAmount.lte(ethers.utils.parseEther(this.depositAmount))){
	            this.approvalRequired = true;
	        } else {
	            this.approvalRequired = false;
	        }
		},
		async checkName(){
			//let response = await this.ethers.resolveName(this.ENS_Name);
			this.nameManager = new ethers.Contract(
				this.nameManagerAddress,
				this.nameManager_ABI,
				this.signer
			);			
            // add in check to make sure name is already registered !ENSRegCont.availiable
		},
		async approve() {
			this.ERC20 = new ethers.Contract(
				this.depositToken,
				this.IERC20_ABI,
				this.signer
			);
			const approve = await this.ERC20.approve(
				this.stakeYourNameAddress,
				ethers.constants.MaxUint256
			);
		},
		async disapprove() {
			this.ERC20 = new ethers.Contract(
				this.DAI_Contract,
				this.IERC20_ABI,
				this.signer
			);
			const approve = await this.ERC20.approve(
				this.stakeYourNameAddress,
				ethers.utils.parseUnits("0",0)
				);
		},
		
		async makeDeposit() {
		    this.ERC20 = new ethers.Contract(
				this.depositToken,
				this.IERC20_ABI,
				this.signer
			);
			const decimals = await this.ERC20.decimals();
			const results = await this.stakeYourName.deposit(
				ethers.utils.getAddress(this.depositToken),
				ethers.utils.parseUnits(this.depositAmount,decimals)
			)
			this.findVault();
		},
		async getOwner() {
			const getContractOwner = await this.stakeYourName.getOwner(null);
			this.contractOwner = getContractOwner;
		},
		async findVault() {
			const userVault = await this.stakeYourName.findVault(
				this.signer.getAddress()
			);
			this.userVault = userVault;
			if(userVault !== null){
			    this.repeatUser = true;
			    this.updateVault();
			    //window.vaultLink.href = "https://kovan.etherscan.io/address/" + this.userVault;
			}
			//this.txPending = true;
		},
		async withdrawAsset1() {
		    const results = await this.stakeYourName.withdraw(
		    this.asset1,
		    ethers.constants.MaxUint256
		    )    
		},
		async withdrawAsset2() {
		    const results = await this.stakeYourName.withdraw(
		    this.asset2,
		    ethers.constants.MaxUint256
		    )    
		},
		async withdrawAsset3() {
		    const results = await this.stakeYourName.withdraw(
		    this.asset3,
		    ethers.constants.MaxUint256
		    )    
		},
		async withdrawAsset4() {
		    const results = await this.stakeYourName.withdraw(
		    this.asset4,
		    ethers.constants.MaxUint256
		    )    
		},
		
		async updateAsset1() {
		    switch(this.asset1) {
                case this.DAI_Contract:
                    this.assetToken1 = "DAI"
                break;
                case this.AAVE_Contract:
                    this.assetToken1 = "Aave"
                break;
                case this.USDT_Contract:
                    this.assetToken1 = "USDT"
                break;
                case this.USDC_Contract:
                    this.assetToken1 = "USDC"
                break;
                case this.UNISWAP_Contract:
                    this.assetToken1 = "UNISWAP"
                break;
                case this.TUSD_Contract:
                    this.assetToken1 = "TUSD"
                break;
            }
		    this.ERC20 = new ethers.Contract(
				this.asset1,
				this.IERC20_ABI,
				this.signer
			);
		    this.investmentManager = new ethers.Contract(
				this.investmentManagerAddress,
				this.InvestmentManager_ABI,
				this.signer
			);
			const decimals = await this.ERC20.decimals();
			this.assetAmount1 = ethers.utils.formatUnits(String(await this.investmentManager.getTotal(
			    this.asset1,
			    this.userVault    
			)),decimals)
		},
		async updateAsset2() {
		    if(this.asset2 === this.DAI_Contract){
		        this.assetToken2 = "DAI"
		    } else {
		        this.assetToken2 = "Not DAI"
		    };
		    switch(this.asset2) {
                case this.DAI_Contract:
                    this.assetToken2 = "DAI"
                break;
                case this.AAVE_Contract:
                    this.assetToken2 = "Aave"
                break;
                case this.USDT_Contract:
                    this.assetToken2 = "USDT"
                break;
                case this.USDC_Contract:
                    this.assetToken2 = "USDC"
                break;
                case this.UNISWAP_Contract:
                    this.assetToken2 = "UNISWAP"
                break;
                case this.TUSD_Contract:
                    this.assetToken2 = "TUSD"
                break;
            }
		    this.ERC20 = new ethers.Contract(
				this.asset2,
				this.IERC20_ABI,
				this.signer
			);
		    this.investmentManager = new ethers.Contract(
				this.investmentManagerAddress,
				this.InvestmentManager_ABI,
				this.signer
			);
			const decimals = await this.ERC20.decimals();
			this.assetAmount2 = ethers.utils.formatUnits(String(await this.investmentManager.getTotal(
			    this.asset2,
			    this.userVault    
			)),decimals)
		},
		async updateAsset3() {
		    if(this.asset3 === this.DAI_Contract){
		        this.assetToken3 = "DAI"
		    } else {
		        this.assetToken3 = "Not DAI"
		    };
		    switch(this.asset3) {
                case this.DAI_Contract:
                    this.assetToken3 = "DAI"
                break;
                case this.AAVE_Contract:
                    this.assetToken3 = "Aave"
                break;
                case this.USDT_Contract:
                    this.assetToken3 = "USDT"
                break;
                case this.USDC_Contract:
                    this.assetToken3 = "USDC"
                break;
                case this.UNISWAP_Contract:
                    this.assetToken3 = "UNISWAP"
                break;
                case this.TUSD_Contract:
                    this.assetToken3 = "TUSD"
                break;
            }
		    this.ERC20 = new ethers.Contract(
				this.asset3,
				this.IERC20_ABI,
				this.signer
			);
		    this.investmentManager = new ethers.Contract(
				this.investmentManagerAddress,
				this.InvestmentManager_ABI,
				this.signer
			);
			const decimals = await this.ERC20.decimals();
			this.assetAmount3 = ethers.utils.formatUnits(String(await this.investmentManager.getTotal(
			    this.asset3,
			    this.userVault    
			)),decimals)
		},
		async updateAsset4() {
		    if(this.asset4 === this.DAI_Contract){
		        this.assetToken4 = "DAI"
		    } else {
		        this.assetToken4 = "Not DAI"
		    };
		    switch(this.asset4) {
                case this.DAI_Contract:
                    this.assetToken4 = "DAI"
                break;
                case this.AAVE_Contract:
                    this.assetToken4 = "Aave"
                break;
                case this.USDT_Contract:
                    this.assetToken4 = "USDT"
                break;
                case this.USDC_Contract:
                    this.assetToken4 = "USDC"
                break;
                case this.UNISWAP_Contract:
                    this.assetToken4 = "UNISWAP"
                break;
                case this.TUSD_Contract:
                    this.assetToken4 = "TUSD"
                break;
            }
		    this.ERC20 = new ethers.Contract(
				this.asset4,
				this.IERC20_ABI,
				this.signer
			);
		    this.investmentManager = new ethers.Contract(
				this.investmentManagerAddress,
				this.InvestmentManager_ABI,
				this.signer
			);
			const decimals = await this.ERC20.decimals();
			this.assetAmount4 = ethers.utils.formatUnits(String(await this.investmentManager.getTotal(
			    this.asset4,
			    this.userVault    
			)),decimals)
		},
		
		async updateVault() {
		    this.vault = new ethers.Contract(
				this.userVault,
				this.UserVault_ABI,
				this.signer
			);
			this.nameManager = new ethers.Contract(
				this.nameManagerAddress,
				this.nameManager_ABI,
				this.signer
			);
			try {this.asset1 = await this.vault.assets(0);} catch(err){};
			try {this.asset2 = await this.vault.assets(1);} catch(err){};
			try {this.asset3 = await this.vault.assets(2);} catch(err){};
    		try {this.asset4 = await this.vault.assets(3);} catch(err){};
    		
			// this is poor, it relies on hiding errors
			try {this.readableName1 = String(await this.vault.readSubName(this.vault.names(0),1)) + ".eth";} catch(err){};
			try {this.nameExpiry1 = String(Math.floor(await this.nameManager.getNameExpiry(this.vault.names(0))/86400 - Math.floor(Date.now()/1000)/86400)) + " days";} catch(err){};
			try {this.readableName2 = String(await this.vault.readSubName(this.vault.names(1),1)) + ".eth";} catch(err){};
			try {this.nameExpiry2 = String(Math.floor(await this.nameManager.getNameExpiry(this.vault.names(1))/86400 - Math.floor(Date.now()/1000)/86400)) + " days";} catch(err){};
			try {this.readableName3 = String(await this.vault.readSubName(this.vault.names(2),1)) + ".eth";} catch(err){};
			try {this.nameExpiry2 = String(Math.floor(await this.nameManager.getNameExpiry(this.vault.names(2))/86400 - Math.floor(Date.now()/1000)/86400)) + " days";} catch(err){};
			try {this.readableName4 = String(await this.vault.readSubName(this.vault.names(3),1)) + ".eth";} catch(err){};
			try {this.nameExpiry2 = String(Math.floor(await this.nameManager.getNameExpiry(this.vault.names(3))/86400 - Math.floor(Date.now()/1000)/86400)) + " days";} catch(err){};
			
		},
		async openEtherscan() {
		    window.open("https://kovan.etherscan.io/address/" + this.userVault, "_blank");
		},
        async mounted() {
            ethereum.on('chainChanged', (_chainId) => window.location.reload());
            ethereum.on('connect', (_connectInfo) => this.initApp());
            window.ethereum.enable().catch(error => {
            // User denied account access
            console.log(error)
            })
        }
    }
});

var userAddress = new Vue({
	el: '#userAddress',
	data: {
		userAddress: null
	}
});
		