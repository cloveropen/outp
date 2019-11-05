<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="out_reg.pid"
              label="门诊号"
              @input="pidChanged($event)"
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.patient_name"
              label="姓名"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.reg_type"
              label="就诊类别"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.patient_type"
              label="患者类别"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.mi_pacc_left"
              label="医保卡余额"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="out_reg.out_diag"
              label="门诊诊断"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.addr"
              label="住址"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>
    </v-card>
    <!--------------------------结算信息栏----------------------------------------------- -->
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="out_reg.pay_should"
              label="应收金额"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.pay_cash"
              label="现金支付"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.pay_nfc"
              label="移动支付"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.pay_pacc"
              label="医保帐户"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.pay_fund"
              label="医保统筹"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-radio-group row v-model="payType">
            <v-flex d-flex
              ><v-radio key="cash" label="现金" value="cash"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="wechat" label="微信" value="wechat"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="alipay" label="支付宝" value="alipay"></v-radio
            ></v-flex>
          </v-radio-group>

          <v-flex d-flex
            ><v-btn id="snap" :disabled="!valid" color="success"
              >预 结 算</v-btn
            >
            <v-btn
              depressed
              :disabled="!valid"
              color="success"
              @click="validate"
              >生成支付码</v-btn
            >
            <v-btn :disabled="!valid_cashout" color="success" @click="cash(out_reg.pid)"
              >确认收款</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >打印收据</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >新增处方</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >查询历史</v-btn
            >
            <v-btn :disabled="!valid" color="warning" @click="validate"
              >下一患者</v-btn
            >
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <!-- -------------------------费用明细栏 --------------------------------------------- -->
    <v-data-table
      :headers="headers"
      :items="fee_details"
      :items-per-page="10"
      class="elevation-1"
    ></v-data-table>
    <!-- -----------------------------待交款患者列表-------------------------------------------- -->
    <v-item-group active-class="primary">
      <v-container>
        <v-row>
          <v-col v-for="treg in fee_bfpays" :key="treg.seq" cols="12" md="4">
            <v-item v-slot:default="{ active, toggle }">
              <v-card class="mx-auto" max-width="400">
                <v-img
                  :src="treg.pic1"
                  class="white--text align-end"
                  height="200px"
                >
                </v-img>
                <v-card-text class="text--primary">
                  <div class="pb-0">
                    &emsp;姓&emsp;名:&emsp;{{ treg.patient_name }}
                  </div>
                  <div>&emsp;门诊号:&emsp;{{ treg.pid }}</div>
                  <div>&emsp;应收款:&emsp;{{ treg.pay_should }}</div>
                </v-card-text>
                <v-card-actions>
                  <v-btn color="orange" text @click="sch_pidlist(treg.pid)">
                    查询
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-item>
          </v-col>
        </v-row>
      </v-container>
    </v-item-group>
  </v-container>
</template>

<script>
import {
  get_reg4cash,
  get_feedetail4cash,
  get_feedreglist,
  get_regopcode,
  cashout
} from "../scripts/outcash.js";

export default {
  data: () => ({
    valid: true,
    valid_cashout: true,
    out_reg: {
      seq: 0,
      hsp_code: process.env.VUE_APP_HSP_CODE,
      pid: "", //门诊号
      ex_pid: "",
      patient_name: "",
      patient_type: "",
      reg_type: "",
      presc_nmb: "",
      out_diag: "", //门诊诊断
      mi_pacc_left: 0.0, //医保卡余额
      addr: "", //住址
      pay_should: 0.0, //应收金额
      pay_cash: 0.0, //实收现金
      pay_nfc: 0.0, //移动支付
      pay_pacc: 0.0, //医保帐户
      pay_fund: 0.0 //医保统筹
    },
    payType: "cash", //支付方式选择
    headers: [
      {
        text: "项目名称",
        align: "left",
        sortable: false,
        value: "item_name"
      },
      { text: "单价", value: "real_price" },
      { text: "数量", value: "quantity" },
      { text: "天数", value: "days" },
      { text: "开具时间", value: "cal_time" },
      { text: "医师", value: "cal_opcode" }
    ],
    fee_details: [],
    fee_bfpays: [],
    topcode: "",
    tgc: ""
  }),

  created() {
    console.log("created");
    this.topcode = get_regopcode().split("|")[0];
    this.tgc = get_regopcode().split("|")[1];
  },
  mounted() {
    console.log("mounted");
    //console.log("tfee_list begin ");
    get_feedreglist(this.topcode, this.tgc).then(data => {
      //console.log("tfees_list=" + data);
      let obj = JSON.parse(data);
      this.fee_bfpays = JSON.parse(obj.outdata);
      // this.fee_details = JSON.parse(obj.outdata)
    });
  },
  methods: {
    validate() {
      if (this.$refs.form.validate()) {
        this.snackbar = true;
      }
    },
    reset() {
      this.$refs.form.reset();
    },
    resetValidation() {
      this.$refs.form.resetValidation();
    },
    pidChanged(e) {
      console.log("pid=" + e);
      let tpid = e.trim();
      if (tpid.length == 12) {
        get_reg4cash(tpid, this.topcode, this.tgc).then(data => {
          //console.log("t9s=" + data);
          let obj = JSON.parse(data);
          this.out_reg = JSON.parse(obj.outdata);
        });
        console.log("tfees begin ");
        get_feedetail4cash(tpid, this.topcode, this.tgc).then(data => {
          //console.log("tfees=" + data);
          let obj = JSON.parse(data);
          this.fee_details = JSON.parse(obj.outdata);
        });
      }
    },
    sch_pidlist(tpid) {
      //console.log("from list pid=" + tpid);

      if (tpid.length == 12) {
        get_reg4cash(tpid, this.topcode, this.tgc).then(data => {
          //console.log("t9s=" + data);
          let obj = JSON.parse(data);
          this.out_reg = JSON.parse(obj.outdata);
        });
        //console.log("tfees begin ");
        get_feedetail4cash(tpid, this.topcode, this.tgc).then(data => {
          //console.log("tfees=" + data);
          let obj = JSON.parse(data);
          this.fee_details = JSON.parse(obj.outdata);
        });
      }
    },
    cash(tpid) {
      //确认收款
      console.log("cahs tpid=" + tpid);
      let toutstr = "";
      toutstr = cashout(tpid, this.topcode, this.tgc);
      this.valid_cashout = false;
      window.alert("收款完成" + toutstr);
    }
    // ---------------------end methods----------------
  }
};
</script>
