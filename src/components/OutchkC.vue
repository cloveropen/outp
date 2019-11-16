<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%" justify-center>
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="topcode" label="操作员号" required :disabled="valid"></v-text-field>&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="tpasswd" :rules="passRules" label="密码" required type="password" :disabled="valid"></v-text-field>&emsp;&emsp;
          </v-flex>

          <v-flex d-flex>
            <v-btn color="success" :disabled="valid" @click="loginChk">验证</v-btn>
            &emsp;&emsp;
          </v-flex>
          <v-row>
            <v-flex d-flex flex-wrap>
              &emsp;&emsp;
              <v-text-field v-model="topname" label="操作员姓名" disabled></v-text-field>&emsp;&emsp;
            </v-flex>
            <br />
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="tbeg" label="开始时间" disabled></v-text-field>&emsp;&emsp;
            </v-flex>
            <v-flex d-flex> <v-text-field v-model="tend" label="结束时间" disabled></v-text-field>&emsp;&emsp; </v-flex>
          </v-row>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex
            ><v-btn id="snap" :disabled="!valid" color="success" @click="outchk_calc($event)">计算</v-btn>
            <v-btn depressed :disabled="!valid" color="success" @click="outchk_commit($event)">确认交班</v-btn>
            <v-btn :disabled="!valid_prn" color="success" @click="prnoutchk($event)">打印结算表</v-btn>
            <v-btn :disabled="!valid_prn" color="success" @click="prncancel3($event)">打印退款明细</v-btn>
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <v-expansion-panels inset focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple><b>交班结算汇总表</b></v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------交班结算栏 --------------------------------------------- -->
          <v-data-table :headers="headers_chk_sum" :items="chk_sums" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header ripple><b>交班结算分项明细表</b></v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------交班结算分项明细栏 --------------------------------------------- -->
          <v-data-table :headers="headers_chk_detail" :items="chk_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退挂号明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退挂号明细栏 --------------------------------------------- -->
          <v-data-table :headers="headers_reg" :items="out_regs" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退收款明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退收款明细栏 --------------------------------------------- -->
          <v-data-table :headers="headers_fee" :items="fee_details" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退预交金明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退预交金明细栏 --------------------------------------------- -->
          <v-data-table :headers="headers_deposit" :items="deposits" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>出院结算召回明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------出院结算召回明细 --------------------------------------------- -->
          <v-data-table :headers="headers_discharge" :items="discharges" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
    <!--     打印门诊收款结算交接班表---------------------------------------- -->
    <v-row no-gutters>
      <v-col cols="12" sm="12">
        <v-parallax height="300" dark src="https://cdn.vuetifyjs.com/images/parallax/material2.jpg">
          <div id="print_outchk">
            <v-card class="pa-2" outlined style="background-color: lightgrey;" tile>
              门诊收款结算交接班表打印样式
            </v-card>
          </div>
        </v-parallax>
      </v-col>
    </v-row>
    <!--     打印退号 款 预交金表---------------------------------------- -->
    <v-row no-gutters>
      <v-col cols="12" sm="12">
        <v-parallax height="700" dark :src="require('../assets/img/blank_cash.jpg')">
          <div id="print_cancel3">
            <v-card class="pa-2" outlined style="background-color: lightgrey;" tile>
              退号(款)(预交金)表打印样式
            </v-card>
          </div>
        </v-parallax>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { fetch_cash_async, post_cash_async, get_regopcode } from "../scripts/outcash.js";
export default {
  data: () => ({
    topcode: "",
    topname: "",
    tpasswd: "",
    tgc: "",
    passRules: [v => !!v || "用户密码不能为空", v => v.length >= 6 || "用户密码长度必须超过6个字符"],
    tbeg: "",
    tend: "",
    headers_chk_sum: [
      {
        text: "操作编码",
        align: "left",
        sortable: false,
        value: "opcode"
      },
      { text: "姓名", value: "opname" },
      { text: "开始时间", value: "bd" },
      { text: "截止时间", value: "ed" },
      { text: "交班流水号", value: "chk_flow" },
      { text: "总费用", value: "all_sum" },
      { text: "现金", value: "cash_sum" },
      { text: "个人帐户", value: "pacc_sum" },
      { text: "医保统筹", value: "fund_sum" },
      { text: "农合统筹", value: "fund_nh_sum" },
      { text: "商业保险", value: "fund_commeric" },
      { text: "微信支付", value: "weixin_sum" },
      { text: "支付宝支付", value: "alipay_sum" },
      { text: "银行卡支付", value: "unionpay_sum" },
      { text: "支票", value: "check_sum" },
      { text: "抵用券", value: "voucher_sum" },
      { text: "特批欠款", value: "spec_sum" },
      { text: "备注", value: "remark" }
    ],
    headers_chk_detail: [
      {
        text: "操作编码",
        align: "left",
        sortable: false,
        value: "opcode"
      },
      { text: "姓名", value: " opname" },
      { text: "交班类别", value: "chk_type" },
      { text: "开始时间", value: " bd" },
      { text: "截止时间", value: "ed" },
      { text: "交班明细流水号", value: "chk_flow_detail" },
      // { text: "开始流水号", value: "bflow" },
      // { text: "截止流水号", value: "eflow" },
      { text: "开始收据号", value: "binvoice_nmb" },
      { text: "截止收据号", value: "einvoice_nmb" },
      { text: "交易类型", value: "trade_type" },
      { text: "收据张数", value: "paper_num" },
      { text: "总费用", value: "all_sum" },
      { text: "现金", value: "cash_sum" },
      { text: "个人帐户", value: "pacc_sum" },
      { text: "医保统筹", value: "fund_sum" },
      { text: "农合统筹", value: "fund_nh_sum" },
      { text: "商业保险", value: "fund_commeric" },
      { text: "微信支付", value: "weixin_sum" },
      { text: "支付宝支付", value: "alipay_sum" },
      { text: "银行卡支付", value: "unionpay_sum" },
      { text: "支票", value: "check_sum" },
      { text: "抵用券支付", value: "voucher_sum" },
      { text: "特批欠款", value: "spec_sum" },
      { text: "出院结算返现金", value: "return_cash" },
      { text: "出院结算返其他", value: "return_ other" }
    ],
    headers_fee: [
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
    headers_reg: [
      {
        text: "患者姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "挂号费", value: "reg_price" },
      { text: "诊查费", value: "check_price" },
      { text: "退号时间", value: "reg_time" },
      { text: "操作员", value: "reg_opcode" },
      { text: "现金支付", value: "pay_cash" },
      { text: "个人帐户", value: "pay_pacc" },
      { text: "统筹", value: "pay_fund" },
      { text: "移动支付", value: "pay_nfc" },
      { text: "挂号类别", value: "reg_type" },
      { text: "门诊号", value: "pid" }
    ],
    headers_deposit: [
      {
        text: "患者姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "退号时间", value: "pay_time" },
      { text: "操作员", value: "opcode" },
      { text: "预交金额", value: "pay_sum" },
      { text: "现金支付", value: "pay_cash" },
      { text: "微信支付", value: "pay_weixin" },
      { text: "支付宝", value: "pay_alipay" },
      { text: "银联支付", value: "pay_union" },
      { text: "支票支付", value: "pay_chk" },
      { text: "其他支付", value: "pay_other" },
      { text: "备注", value: "remark" },
      { text: "住院号", value: "pid" }
    ],
    headers_discharge: [
      {
        text: "患者姓名",
        align: "left",
        sortable: false,
        value: "patient_name"
      },
      { text: "召回时间", value: "settle_time" },
      { text: "操作员", value: "opcode" },
      { text: "医疗总费用", value: "all_sum" },
      { text: "返现金", value: "change_cash" },
      { text: "返支票", value: "change_check" },
      { text: "返微信", value: "change_weixin" },
      { text: "返支付宝", value: "change_alipay" },
      { text: "返银联", value: "change_union" },
      { text: "入院时间", value: "in_time" },
      { text: "出院时间", value: "out_time" },
      { text: "备注", value: "pid" }
    ],
    chk_sums: [],
    chk_details: [],
    out_regs: [],
    fee_details: [],
    deposits: [],
    discharges: [],
    valid: false,
    valid_prn: false
  }),

  created() {
    // console.log("created");
  },
  mounted() {
    //  console.log("mounted");
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
    loginChk() {
      let sel = this;
      let tinstr = '{"opid":"' + this.topcode + '","opname":"","oppass":"' + this.tpasswd + '","opstatus":""}';
      post_cash_async(process.env.VUE_APP_LOGIN_URL, tinstr).then(data => {
        let topstatus = data.opstatus;
        if (topstatus === "200") {
          localStorage.setItem("user", JSON.stringify(data));
          //sel.$parent.$router.push({ path: "/" });
          // 提交保存登录凭证数据
          data.hsp_code = process.env.VUE_APP_HSP_CODE;
          var date = new Date();
          data.valid_time = date.toUTCString();
          // -----------------------------------------------------------------------------------------------
          post_cash_async(process.env.VUE_APP_LOGINREC_URL + "/savetgc", JSON.stringify(data)).then(data => {
            console.log("用户信息保存成功=" + JSON.stringify(data));
            // --查询操作员姓名和交班的开始时间,截止时间默认是当前时间
            sel.tgc = get_regopcode().split("|")[1];
            let thsp_code = process.env.VUE_APP_HSP_CODE;
            let turl = process.env.VUE_APP_REG_URL + "/searchchksumlast/" + thsp_code + "/" + sel.topcode + "/" + sel.tgc;
            fetch_cash_async(turl, "get").then(data => {
              console.log("data=" + JSON.stringify(data));
              if (data.resultCode === "0") {
                let toutdata = JSON.parse(data.outdata);
                sel.valid = true;
                sel.topname = toutdata.opname;
                sel.tbeg = toutdata.bd;
                sel.tend = toutdata.ed;
              } else {
                window.alert("查询失败" + data.errorMsg);
              }
            });
          });
          // ------------------------------------------------------------------------------------------------
        }
      });
    },
    // --------------------------计算交班结算(预结算)------------------------------------------------------
    outchk_calc(e) {
      // 入参:thsp_code + "|" + ted + "|" + topcode + "|" + tgc; 截止时间入参格式yyyy-mm-dd hh24:mi:ss
      console.log("e=" + e.target.innerText);
      let tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tend + "|" + this.topcode + "|" + this.tgc;
      //console.log("tinstr=" + tinstr);
      post_cash_async(process.env.VUE_APP_REG_URL + "/outchkcalc", JSON.stringify(tinstr)).then(data => {
        // console.log("计算交班结算(预结算):" + JSON.stringify(data));
        if (data.resultCode === "0") {
          let tchk_list = Array.of();
          tchk_list = data.outdata.split("|");
          //console.log("-----tchk_list[0]=" + tchk_list[0]);
          this.chk_sums = JSON.parse(tchk_list[0]);
          // console.log("-----tchk_list[1]=" + tchk_list[1]);
          this.chk_details = JSON.parse(tchk_list[1]);
          //console.log(
          //  "tchk_list[0]=" + tchk_list[0] + " tchk_list[1]=" + tchk_list[1]
          //);
        } else {
          window.alert("查询失败" + data.errorMsg);
        }
      });
      // -----------------------查询退款明细-------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      let turl = process.env.VUE_APP_REG_URL + "/searchfeemulti/backcash/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退款明细data=" + JSON.stringify(data))
        if (data.resultCode == "0") {
          this.fee_details = JSON.parse(data.outdata);
          //console.log("查询退款明细data2");
        }
      });
      // -----------------------查询退号明细-------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      turl = process.env.VUE_APP_REG_URL + "/searchoutregmulti/backreg/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退号明细:"+JSON.stringify(data));
        if (data.resultCode == "0") {
          this.out_regs = JSON.parse(data.outdata);
          //console.log("查询退号明细2");
        }
      });
      //----------------------查询预交金退款明细 -----------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      turl = process.env.VUE_APP_REG_URL + "/searchdepositmulti/backcash/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询预交金明细:"+JSON.stringify(data));
        if (data.resultCode == "0") {
          this.deposits = JSON.parse(data.outdata);
          //console.log("查询预交金明细2");
        }
      });
      //-----------------------查询出院召回明细 ------------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      turl = process.env.VUE_APP_REG_URL + "/searchdischargemulti/backcash/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询出院召回明细:"+JSON.stringify(data));
        if (data.resultCode == "0") {
          this.discharges = JSON.parse(data.outdata);
          //console.log("查询出院召回明细2");
        }
      });
    },
    // -------------------------交班结算确认---------------------------------------------------------------
    outchk_commit(e) {
      // 入参:thsp_code + "|" + ted + "|" + topcode + "|" + tgc; 截止时间入参格式yyyy-mm-dd hh24:mi:ss
      console.log("e=" + e.target.innerText);
      let tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tend + "|" + this.topcode + "|" + this.tgc;
      //console.log("tinstr=" + tinstr);
      post_cash_async(process.env.VUE_APP_REG_URL + "/outchkcommit", JSON.stringify(tinstr)).then(data => {
        //console.log("计算交班结算:" + JSON.stringify(data));
        if (data.resultCode === "0") {
          let tchk_list = Array.of();
          tchk_list = data.outdata.split("|");
          this.chk_sums = JSON.parse(tchk_list[0]);
          // console.log("-----tchk_list[1]=" + tchk_list[1]);
          this.chk_details = JSON.parse(tchk_list[1]);
          //console.log(
          //  "tchk_list[0]=" + tchk_list[0] + " tchk_list[1]=" + tchk_list[1]
          // );
        } else {
          window.alert("查询失败" + data.errorMsg);
        }
      });
      // -----------------------查询退款明细-------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      let turl = process.env.VUE_APP_REG_URL + "/searchfeemulti/backcash/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退款明细data=" + JSON.stringify(data))
        if (data.resultCode == "0") {
          this.fee_details = JSON.parse(data.outdata);
          //console.log("查询退款明细data2");
        }
      });
      // -----------------------查询退号明细-------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      turl = process.env.VUE_APP_REG_URL + "/searchoutregmulti/backreg/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退号明细:"+JSON.stringify(data));
        if (data.resultCode == "0") {
          this.out_regs = JSON.parse(data.outdata);
          //console.log("查询退号明细2");
        }
      });
      //----------------------查询预交金退款明细 -----------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      turl = process.env.VUE_APP_REG_URL + 
        "/searchdepositmulti/backcash/" + tinstr + 
        "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询预交金明细:"+JSON.stringify(data));
        if (data.resultCode == "0") {
          this.deposits = JSON.parse(data.outdata);
          //console.log("查询预交金明细2");
        }
      });
      //-----------------------查询出院召回明细 ------------------------------------------------------
      tinstr = process.env.VUE_APP_HSP_CODE + "|" + this.tbeg + "|" + this.tend;
      turl = process.env.VUE_APP_REG_URL + 
        "/searchdischargemulti/backcash/" + 
        tinstr + "/" + this.topcode + "/" + this.tgc;
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询出院召回明细:"+JSON.stringify(data));
        if (data.resultCode == "0") {
          this.discharges = JSON.parse(data.outdata);
          //console.log("查询出院召回明细2");
        }
      });
      this.valid_prn = true;
    },
    // --------------------------打印交班结算表-------------------------------------------------------------
    prnoutchk(e) {
      console.log("e=" + e.target.innerText);
      this.$htmlToPaper("print_outchk");
    },
    // --------------------------打印退款明细--------------------------------------------------------------
    prncancel3(e) {
      console.log("e=" + e.target.innerText);
      this.$htmlToPaper("print_cancel3");
    }
    // ---------------------end methods----------------
  }
};
</script>
