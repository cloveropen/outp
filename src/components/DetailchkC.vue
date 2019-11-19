<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
           <v-layout row wrap>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-radio-group row v-model="tdatetype">
            <v-flex d-flex
              ><v-radio key="today" label="今天" value="today"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="schedule_last" label="上班次" value="schedule_last"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="yesterday" label="昨天" value="yesterday"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="3daysbf" label="三天内" value="3daysbf"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="weekbf" label="一周内" value="weekbf"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="monthbf" label="一月内" value="monthbf"></v-radio
            ></v-flex>
          </v-radio-group>
       
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="topcode"
              label="操作员号" readonly
              required
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>         
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex>
            <v-btn
              depressed
              color="success"
              @click="sch_chk"
              >查询</v-btn
            >
            <v-btn color="success" @click="reset">导出汇总</v-btn>
            <v-btn color="success" @click="reset">导出明细</v-btn>
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <v-expansion-panels popout focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>交班汇总</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table
            :headers="headers_sum"
            :items="chk_sums"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>交班明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table
            :headers="headers_detail"
            :items="chk_details"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
  </v-container>
</template>

<script>
import { fetch_cash_async, get_regopcode } from "../scripts/outcash.js";
export default {
  data: () => ({
    topcode: "",
    tgc: "",
    tdatetype: "schedule_last",    
    headers_sum: [
      {
        text: "操作员编码",
        align: "left",
        sortable: true,
        value: "opcode"
      },
      { text: "姓名", value: "opname" },
      { text: "开始时间", value: "bd" },
      { text: "截止时间", value: "ed" },
      { text: "结算时间", value: "chk_time" },
      { text: "结算员号", value: "chk_opcode" },
      { text: "交班流水号", value: "chk_flow" },
      { text: "总费用", value: "all_sum" },
      { text: "现金", value: "cash_sum" },
      { text: "个人帐户", value: "pacc_sum" },
      { text: "医保统筹", value: "fund_sum" },
      { text: "农合统筹", value: "fund_nh_sum" },
      { text: "商业保险", value: "fund_commeric" },
      { text: "微信支付", value: "weixin_sum" },
      { text: "支付宝", value: "alipay_sum" },
      { text: "银行卡", value: "unionpay_sum" },
      { text: "支票", value: "check_sum" },
      { text: "抵用券", value: "voucher_sum" },
      { text: "特批欠款", value: "spec_sum" },
      { text: "顺序号", value: "seq" },
      { text: "备注", value: " remark" }
    ],
    headers_detail: [
      {
        text: "操作员编码",
        align: "left",
        sortable: true,
        value: "opcode"
      },
      { text: "姓名", value: "opname" },
      { text: "交班类别", value: "chk_type" },
      { text: "开始时间", value: "bd" },
      { text: "截止时间", value: "ed" },
      { text: "结算时间", value: "chk_time" },
      { text: "结算员号", value: "chk_opcode" },
      { text: "交班明细流水号", value: "chk_flow_detail" },
      { text: "开始流水号", value: "bflow" },
      { text: "截止流水号", value: "eflow" },
      { text: "开始收据号", value: "binvoice_nmb" },
      { text: "截止收据号", value: "einvoice_nmb" },
      { text: "收据张数", value: "paper_num" },
      { text: "总费用", value: "all_sum" },
      { text: "现金", value: "cash_sum" },
      { text: "个人帐户", value: "pacc_sum" },
      { text: "医保统筹", value: "fund_sum" },
      { text: "农合统筹", value: "fund_nh_sum" },
      { text: "商业保险", value: "fund_commeric" },
      { text: "微信支付", value: "weixin_sum" },
      { text: "支付宝", value: "alipay_sum" },
      { text: "银行卡", value: "unionpay_sum" },
      { text: "支票", value: "check_sum" },
      { text: "抵用券", value: "voucher_sum" },
      { text: "特批欠款", value: "spec_sum" },
      { text: "出院结算返回现金", value: "return_cash" },
      { text: "出院结算返回其他", value: "return_other" },
      { text: "交易类型", value: "trade_type" }
    ],    
    chk_sums: [],
    chk_details: []
  }),

  created() {
    this.topcode = get_regopcode().split("|")[0];
    this.tgc = get_regopcode().split("|")[1];
  },
  mounted() {
    console.log("mounted");
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
    sch_chk() {
      console.log("开始查询门诊结算信息");
      let tinstr = this.tdatetype + "|" + process.env.VUE_APP_HSP_CODE + "|" + this.topcode;
      let turl = process.env.VUE_APP_REG_URL + "/searchchksummulti/chkshifts/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      console.log("turl=" + turl);
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退款明细data=" + JSON.stringify(data))
        if (data.resultCode == "0") {
          let tlist = Array.of();
          tlist = data.outdata.split("|");
          console.log("-----tlist[0]=" + tlist[0]);
          this.chk_sums = JSON.parse(tlist[0]);
          console.log("-----tlist[1]=" + tlist[1]);
          this.chk_details = JSON.parse(tlist[1]);         
        }
      });
    }
    // ---------------------end methods----------------
  }
};
</script>
