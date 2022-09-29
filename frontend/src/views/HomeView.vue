<template>
  <div class="home">

    <div class="content">
      <br>
      <el-tooltip
        v-if="wallet"
        effect="dark"
        :content="wallet"
        placement="bottom"
      >
        <el-button  class="wallet-address" type="success" round>{{wallet.slice(0,5) + '...' + wallet.slice(wallet.length - 5)}}</el-button>
      </el-tooltip>
      <el-button v-else class="wallet-address" type="warning" round  @click="connect">Connect your wallet</el-button>

      <el-button v-if="!upload_mode" @click="change_mode">Upload</el-button>
      <el-button v-if="upload_mode" @click="change_mode">View</el-button>
      <el-button v-if="upload_mode" @click="clear_all">Clear All</el-button>

      <br v-if="!upload_mode">
      <br v-if="!upload_mode">
      <div class="mt-4" v-if="!upload_mode">
        <el-input
          v-model="search_input"
          placeholder=""
          class="input-with-select"
          @change="search"
        >
          <template #prepend>
            <el-select v-model="search_select" placeholder="Select" style="width: 115px">
              <el-option label="TokenID" value="1" />
              <el-option label="Labels" value="2" />
            </el-select>
          </template>
          <template #append>
          <el-button @click="search">
            <el-icon style="vertical-align: middle">
              <Search />
            </el-icon>
          </el-button>
          </template>
        </el-input>
      </div>
      <br>

      <el-table v-if="!upload_mode" :data="tableData" style="width: 100%" align="center">
        <el-table-column fixed prop="tokenID" label="TokenID" width="80" :show-overflow-tooltip="true" align="center"/>
        <el-table-column prop="name" label="Name" width="120" :show-overflow-tooltip="true" align="center"/>
        <!-- <el-table-column prop="poster" label="Poster" width="120" :show-overflow-tooltip="true" align="center"/> -->
        <el-table-column prop="description" label="Poster" width="120" :show-overflow-tooltip="true" align="center">
          <template #default="scope">
            <div style="display: flex; align-items: center">
                <el-image :src="scope.row.description"/>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="owner" label="Owner" width="120" :show-overflow-tooltip="true" align="center"/>
        <el-table-column fixed="right" label="Operations" width="200" align="center">
          <template #default="scope">
            <el-button link type="primary" size="small" @click="viewClick(scope.$index)"
              >View</el-button
            >
            <el-button link type="primary" size="small" @click="downloadClick(scope.$index)">Download</el-button>
            <el-button link type="primary" size="small" @click="editLabelClick(scope.$index)">Edit Label</el-button>
          </template>
        </el-table-column>
        <el-table-column prop="labels" label="Labels" width="120" :show-overflow-tooltip="true" align="center"/>

      </el-table>

      <el-dialog v-model="dialogTableVisible" title="Labels">
        <el-table :data="gridData">
          <el-table-column property="labelID" label="labelID" width="100" />
          <el-table-column property="tokenID" label="tokenID" width="100" />
          <el-table-column property="user" label="Address" width="100" :show-overflow-tooltip="true"/>
          <el-table-column property="label" label="Label" width="100"/>
          <el-table-column label="Operation" align="center">
            <template #default="scope">
              <el-button type="danger" size="small" @click="removeLabel(scope.$index)">Remove</el-button>
            </template>
          </el-table-column>
        </el-table>
        <br>
        <el-row :gutter="20">
          <span class="w-50 m-2 inline-flex items-center">Add a new label</span>
          <el-input class="" v-model="new_label" placeholder="Please input" size="small">
            <template #append>
              <el-button class="" @click="add_label()">Add</el-button>
            </template>
          </el-input>
          <br>
          <!-- <center></center> -->
        </el-row>
        <br>
        <el-tooltip
          v-if="wallet"
          effect="dark"
          :content="wallet"
          placement="bottom"
        >
          <el-button class="wallet-address" type="success" round>{{wallet.slice(0,5) + '...' + wallet.slice(wallet.length - 5)}}</el-button>
        </el-tooltip>
        <el-button v-else class="wallet-address" type="warning" round  @click="connect">Connect your wallet</el-button>
      </el-dialog>

      <br>
      <span v-if="(!upload_mode) && (searching_data)">Fetching data...</span>
      <el-button v-if="(!upload_mode) && (!searching_data)" @click="get_more_data" round>Get More Data</el-button>

      <div v-if="upload_mode">
        <el-row>
          <el-col :span="16">
          
              <span>Select your model file</span>
            <br>
            <el-upload
              ref="upload"
              class="upload-demo"
              :limit="1"
              :on-exceed="handleExceed"
              :auto-upload="false"
              :on-change="handleChange"
              :on-remove="handleRemove"
              accept=".glb, .gltf"
              
            >
              <template #trigger>
                <el-button type="primary">Select File</el-button>
              </template>
              <template #tip>
                <div class="el-upload__tip text-red">
                  limit 1 file, new file will cover the old file
                </div>
              </template>
            </el-upload>
    
            <div>
              <div>
                <el-image style="width: 400px; height: 400px" :src="posterUrl" fit="contain" />
              </div>
              <div>
                <el-button @click="export_poster_to_webp">Screenshot for model as the poster</el-button>
              </div>
            </div>          
          </el-col>
          <el-col :span="8">
            
            <br>            
            <span>Uploader</span>
            <el-input v-model="wallet" placeholder="Please connect your wallet" disabled />

            <br>
            <br>
            <br>
            <br>
              <span>Your NFT.storage API key</span>
              <el-tooltip
                content="<span>If you don't know about <a href='https://nft.storage' target='_blank' style='color:#EE4116;'>NFT.storage</a>, you can visit the website, login and get your API key. Then copy and paste the key into it.</span>"
                raw-content
              >
              <el-input v-model="nft_storage_api_key" placeholder="Please input your NFT.storage API key for store the model file" clearable />
            </el-tooltip>

            <br>
            <br>
            <br>
            <br>
            <span>Give your model a brief name</span>
            <el-input v-model="model_name" placeholder="Please input your model name" clearable />

            <br>
            <br>
            
            <el-button type="warning" round @click="store">
            <el-icon style="vertical-align: right">
              <Upload />
            </el-icon>
            Upload to NFT.storage </el-button>
          <span v-if="metadata">The file is stored in {{metadata.url}}</span>

            <br>
            <br>
          <center><a href="#" class="btnbtn" @click="mint2nft">Mint</a></center>


          </el-col>
        </el-row>
      </div>


    </div>


    <div class="demo">
      <model-viewer id="viewer" ref="viewer" :src="model_src" :poster="model_poster" shadow-intensity="1" data-js-focus-visible camera-controls auto-rotate touch-action="pan-y">
        <div class="annotation" v-if="upload_model_file">This is the preview of your selected model</div>
        <div class="annotation" v-if="default_model">This is the default model for demo</div>
      </model-viewer>
    </div>

  </div>
</template>

<script>
// @ is an alias to /src
import HelloWorld from '@/components/HelloWorld.vue'
import '@google/model-viewer';

import WalletConnectProvider from "@maticnetwork/walletconnect-provider"

import Web3 from "web3"
import Matic from "@maticnetwork/maticjs"

import {abi} from '@/utils/Web3DP.json'
import {abi as label_abi} from '@/utils/Web3DPLabel.json'

import { NFTStorage, File, Blob } from 'nft.storage'

import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'

import Cookies from 'js-cookie'

import imageCompression from 'browser-image-compression';

export default {
  name: 'HomeView',
  components: {
    HelloWorld
  },
  data(){
    return {
      infuraId: '',
      connectors: null, 
      wallet: '',
      tableData: [
        // {
        //   tokenID: '2016-05-03',
        //   name: 'Tom',
        //   address: 'No. 189, Grove St, Los Angeles',
        // },
        // {
        //   tokenID: '2016-05-02',
        //   name: 'Tom',
        //   address: 'No. 189, Grove St, Los Angeles',
        // },
        // {
        //   tokenID: '2016-05-04',
        //   name: 'Tom',
        //   address: 'No. 189, Grove St, Los Angeles',
        // },
        // {
        //   tokenID: '2016-05-01',
        //   name: 'Tom',
        //   address: 'No. 189, Grove St, Los Angeles',
        // },
      ],
      maticProvider: null,
      maticWeb3: null,
      contract: null,
      contract_address: null,
      model_src: "https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb",
      key: 0,
      default_model: true,
      searching_data: false,

      label_contract: null,
      label_contract_address: null,

      upload_mode: false,

      nft_storage_api_key: null,
      upload_model_file: null,
      model_name: null, 
      model_description: null,
      metadata: null,
      step: 0,

      search_input: '',
      search_select: {
        label: 'TokenID',
        value: '1',
      },
      dialogTableVisible: false,
      gridData: [],
      new_label: '',
      current_token_id: null,
      posterUrl: null,
      model_poster: null,
    }
  },
  watch: {
    model_src(){
      if (this.model_src == "https://modelviewer.dev/shared-assets/models/NeilArmstrong.glb"){
        this.default_model = true
      } else{
        this.default_model = false
      }
    },
    nft_storage_api_key(){
      if (this.nft_storage_api_key){
        this.step = 1
      }
    },
    upload_model_file(){
      if (this.upload_model_file){
        this.step = 2
      }
    },
    model_name(){
      if (this.model_name){
        this.step = 3
      }
    },
    metadata(){
      if (this.metadata){
        this.step = 4
      }
    }
  },
  mounted(){
    this.maticProvider = new WalletConnectProvider(
      {
        // host: `https://rpc-mumbai.matic.today`,
        host: `https://rpc-mumbai.maticvigil.com/`,
        callbacks: {
          onConnect: console.log('connected'),
          onDisconnect: console.log('disconnected!')
        }
      }
      
    )
    this.maticWeb3 = new Web3(this.maticProvider)

    var myContractAbi = abi
    // var myContractAddress = '0x752e7e33d74CcB23673Cb013330288B2Af393473'
    // var myContractAddress = '0x2b9BF9B7EBF060b12026116f83f75f1B1589c04a'
    // var myContractAddress = '0x198036c9592e5080170087eC63570333FAc61faE'
    var myContractAddress = '0x14C77219F67E84Ab098aa08f93f984B31038ceB7'
    this.contract_address = myContractAddress
    this.contract = new this.maticWeb3.eth.Contract(myContractAbi, myContractAddress)
    
    // var labelContractAddress = '0xE9c98A0751D60946fE6f37dcDd52531fE0b2Cc4a'
    // var labelContractAddress = '0x7515794fA8a6155603E2C7EF09597a619a2e4617'
    var labelContractAddress = '0xA9aA9A5cDeDBd8144EF352346e810E2A5097EBF8'
    this.label_contract_address = labelContractAddress
    var label_contract_abi = label_abi
    this.label_contract = new this.maticWeb3.eth.Contract(label_contract_abi, labelContractAddress)

    ;(async() => {
      await this.get_data()
      await this.fresh_labels()
    })()
    
    this.nft_storage_api_key = Cookies.get('nft_storage_api_key')

  },
  methods:{
    async fresh_labels(){
      var uu = 0
      while (uu < this.tableData.length){
        var labels = await this.get_labels(this.tableData[uu].tokenID)
        this.tableData[uu].labels = labels.map(item => item.label)
        uu += 1
      }
    },
    async get_labels(token_id){
      var labels = await this.label_contract.methods.getLabels(token_id).call()
      console.log('labels', labels)
      var new_labels = labels.map(item => {
        return {label: item.label, user: item.user, token_id: item.token_id, label_id: item.label_id, status: item.status}
      })
      var result_labels = []
      for (var item of new_labels){
        var uu = 0
        var flag = 0
        while (uu < result_labels.length){
          if (item.label == result_labels[uu]){
            if (parseInt(item.status) == 1){
              result_labels[uu].vote += 1
              flag = 1
              break
            } 
            if (parseInt(item.status) == 0){
              result_labels[uu].vote -= 1
              flag = 1
              break
            }
          }
          uu += 1
        }
        if (flag == 0){
          if (parseInt(item.status) == 1){
            result_labels.push({label: item.label, user: item.user, token_id: item.token_id, label_id: item.label_id, vote: 1})
          } 
          if (parseInt(item.status) == 0){
            result_labels.push({label: item.label, user: item.user, token_id: item.token_id, label_id: item.label_id, vote: -1})
          }
        }
      }
      return result_labels.map(item => {
        if (item.vote > 0){
          return {label: item.label, user: item.user, token_id: item.token_id, label_id: item.label_id, vote: item.vote}
        }
      })
    },
    async search(){
      if (this.search_input == ''){
        this.searching_data = true
        await this.get_data()
        this.searching_data = false
        return
      }

      if (this.search_select.value == '1'){
        // tokenID
        if (!isNaN(this.search_input)){
          var max_num = await this.contract.methods.totalSupply().call()
          if ((parseInt(this.search_input) <= parseInt(max_num)) && (parseInt(this.search_input) > 0)){
            this.searching_data = true
            var id = parseInt(this.search_input)
            var owner = await this.contract.methods.ownerOf(id).call()
            var data = await this.get_model(id)
            this.tableData = []
            this.tableData.push({
              tokenID: id,
              name: data.name,
              description: data.description,
              url: data.url,
              owner: owner,
            })
            this.searching_data = false
          } else {
            ElMessage({
              message: 'Input ID is out of range.',
              type: 'warning'
            })
          }
        } else {
          ElMessage({
            message: 'Please input digital number for tokenID',
            type: 'warning'
          })
        }
        
      }
    },
    async get_more_data(){
      var token_id_list = this.tableData.map(item => {
        return parseInt(item.tokenID)
      })
      console.log(token_id_list)
      if (token_id_list.includes(1)){
        ElMessage({
          message: 'There is no more data.',
          type: 'warning',
        })
      } else {
        this.searching_data = true
        amount = token_id_list[token_id_list.length - 1] - 1
        for (let i = parseInt(amount); i > 0; i--) {
            if (i < parseInt(amount) - 10){
              break
            }
            var owner = await this.contract.methods
              .ownerOf(amount)
              .call()
            var data = await this.get_model(i)
            console.log(data)
            this.tableData.push(
              {
                tokenID: i,
                name: data.name,
                description: data.description,
                url: data.url,
                owner: owner,
                download_able: false,
              }
            )
          }
          this.searching_data = false
      }


    },
    change_mode(){
      this.upload_mode = !this.upload_mode
      console.log(this.upload_mode)
    },
    viewClick(row){
      // console.log(row, scope)
      this.model_poster = this.tableData[row].description
      this.model_src = this.tableData[row].url
      this.tableData[row].download_able = true
    },
    downloadClick(row){
      window.open(this.tableData[row].url)
    },
    async editLabelClick(row){
      this.dialogTableVisible = true
      var tokenid = this.tableData[row].tokenID
      var labels = await this.get_labels(tokenid)
      this.current_token_id = tokenid
      this.gridData = []
      for (let i of labels){
        this.gridData.push({
          labelID: i.label_id,
          label: i.label,
          user: i.user,
          tokenID: i.token_id,
        })
      }

    },
    async add_label(){
      if (this.new_label){
        var transactionParameters = {
          to: this.label_contract_address, // Required except during contract publications.
          from: this.wallet,
          data: this.label_contract.methods.addLabel(this.new_label, this.current_token_id).encodeABI(), // Optional
        }

        var txHash = await ethereum.request({
          method: 'eth_sendTransaction',
          params: [transactionParameters],
        })
        console.log(txHash)
        this.diaglogTableVisible = false
        this.new_label = ''
        // console.log(this.get_labels(this.current_token_id))
      }
    },
    async removeLabel(){
      var transactionParameters = {
        to: this.label_contract_address, // Required except during contract publications.
        from: this.wallet,
        data: this.label_contract.methods.removeLabel(this.new_label, this.current_token_id).encodeABI(), // Optional
      }

      var txHash = await ethereum.request({
        method: 'eth_sendTransaction',
        params: [transactionParameters],
      })
      console.log(txHash)
      this.diaglogTableVisible = false
      
    },
    async connect(){
      if (typeof window.ethereum !== 'undefined') {
        console.log('MetaMask is installed!');
        console.log(ethereum.isConnected())
        // var accounts = await ethereum.request({ method: 'eth_accounts'})
        var accounts = await ethereum.request({ method: 'eth_requestAccounts' });

        console.log(accounts[0])
        this.wallet = accounts[0]
        this.maticWeb3.eth.defaultAccount = accounts[0];
      }
    },
    async get_data(){
      this.searching_data = true
      this.tableData = []
      var amount = await this.contract.methods.totalSupply().call()
      console.log(amount)

      for (let i = parseInt(amount); i > 0; i--) {
        if (i < parseInt(amount) - 10){
          break
        }
        var owner = await this.contract.methods.ownerOf(i).call()
        var data = await this.get_model(i)
        console.log(data)
        this.tableData.push(
          {
            tokenID: i,
            name: data.name,
            description: data.description,
            url: data.url,
            owner: owner,
          }
        )
      }
      this.searching_data = false

    },
    async get_model(tokenID){
      // console.log(this.wallet)
  
      var result = await this.contract.methods
        .tokenURI(tokenID)
        .call()
        
      console.log(result)
      var hash = result.split('://')[1]
      var new_url = `https://ipfs.io/ipfs/${hash}`
      var response = await fetch(new_url);
      var metadata = await response.json();
      var model_url = `https://ipfs.io/ipfs/${metadata['image'].split('://')[1]}` 
      // console.log(metadata['model'])
      console.log(model_url)
      // this.model_src = model_url
      return {name: metadata.name, description: metadata.description, url: model_url}
    },

    async handleChange(file){
      console.log(file)
      let reader = new FileReader();
      reader.onload = (e) => {
          let arrayBuffer = new Uint8Array(reader.result);
          let blob = new Blob([arrayBuffer]);
          let url =  window.URL.createObjectURL(blob);
          this.model_src = url
        }
        reader.readAsArrayBuffer(file.raw);
        this.upload_model_file = file.raw
        
    },

    async store(){
      var client = new NFTStorage({ token: this.nft_storage_api_key })
      var metadata = await client.store({
        name: this.model_name,
        // description: this.model_description,
        description: this.posterUrl,
        image: this.upload_model_file,
      })
      this.metadata = metadata
      Cookies.set('nft_storage_api_key', this.nft_storage_api_key)
      console.log(metadata.url)
      console.log(metadata)
    },

    async mint2nft(){
      if (!this.wallet){
        console.log('not login')
        ElMessage({
          message: 'Please connect your wallet',
          type: 'warning'
        })
        return 
      }
      var transactionParameters = {
        to: this.contract_address,
        from: this.wallet,
        data: this.contract.methods.mintNFT(this.wallet, this.metadata.url).encodeABI(),
        // chainId: '0x3', // Used to prevent transaction reuse across blockchains. Auto-filled by MetaMask.
      };

      // txHash is a hex string
      // As with any RPC call, it may throw an error
      var txHash = await ethereum.request({
        method: 'eth_sendTransaction',
        params: [transactionParameters],
      });
      console.log(txHash)
      this.upload_mode = false
      this.get_data()

    },

    async export_poster_to_webp(){
      var viewer = this.$refs.viewer
      
      var blob = await viewer.toBlob({mimeType: 'image/webp', idealAspect: true, qualityArgument: 0.1});
      // var posterUrl = await viewer.toDataURL({mimeType: 'image/webp'});
      // var posterUrl = URL.createObjectURL(blob);
      console.log(blob)
      this.posterUrl = await this.blobToBase64(blob)
      console.log(this.posterUrl)
    },

    blobToBase64(blob){
      return new Promise((resolve, _) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result);
        reader.readAsDataURL(blob);
      });
    },
    async compress_image(blob){
      var options = {
        maxSizeMB: 0.001,
        useWebWorker: true
      }
      var compressedFile = await imageCompression(blob, options)
      console.log(compressedFile)
      return compressedFile
    },
    clear_all(){
      this.upload_model_file = null
      this.model_name = null
      this.model_description = null
      this.metadata = null 
      this.posterUrl = null
      this.step = 0
    },
  }
}
</script>


<style lang="less">
  .input-with-select .el-input-group__prepend {
    background-color: var(--el-fill-color-blank);
  }
  .wallet-address{
    left: 0
  }
  .annotation{
    color: white;
    background-color: #888888;
    position: absolute;
    transform: translate(10px, 10px);
    border-radius: 10px;
    padding: 10px;
  }
.home {
  display: grid;
  position: relative;
  grid-template-columns: 50% 50%;
    grid-template-areas: "content demo";
}

  .demo {
    position: sticky;
    top: 0;
    height: 100vh;
    flex: 1;
    display: flex;
    justify-content: center;
  }
  model-viewer{
    width: 100%;
    height: 100%;
  }



  /*--Button Styles--*/
.btnbtn {
  position: relative;
  // color: #D1C4E9;
  color: black;
  text-decoration: none;
  text-transform: uppercase;
  letter-spacing: 2px;
  text-shadow: #D1C4E9 1px 0 10px;
  height: 100px;
  width: 100px;
  // border: solid 1px #D1C4E9;
  border: solid 1px #00d7c3;
  border-radius: 100px;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.btnbtn:before {
  content: '';
  position: absolute;
  // background: #9575CD;
  background: #00d7c3;
  // background: #0095d9;
  // background: red;
  // background: orange;
  width: 0;
  height: 0;
  z-index: -1;
  border-radius: 100px;
  box-shadow: 0px 0px 24px 1px rgba(224,199,224,0.2);
  transition: all 900ms cubic-bezier(1.000, -0.195, 0.000, 1.330);
  transition-timing-function: cubic-bezier(1.000, -0.195, 0.000, 1.330);
}

.btnbtn:hover:before {
  width: 85%;
  height: 85%;
  box-shadow: 0 0 10px 0 #00d7c3 inset, 0 0 20px 2px #00d7c3;
  border: 10px solid #00d7c3;
}

.btnbtn:active:before, .btnbtn:focus:before {
  width: 100%;
  height: 100%;
}

</style>  