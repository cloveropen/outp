<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-radio-group row v-model="tdatetype">
            <v-flex d-flex><v-radio key="today" label="今天" value="today"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="schedule" label="本班次" value="schedule"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="schedule—_last" label="上班次" value="schedule—_last"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="yesterday" label="昨天" value="yesterday"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="3daysbf" label="三天内" value="3daysbf"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="weekbf" label="一周内" value="weekbf"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="monthbf" label="一月内" value="monthbf"></v-radio></v-flex>
          </v-radio-group>

          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="topcode" label="操作员号" readonly></v-text-field>&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="tpid" label="门诊号(选填)"></v-text-field>&emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex>
            <v-btn depressed color="success" @click="sch_fee">查询</v-btn>
            <v-btn color="success" @click="reset">导出</v-btn>
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>

    <v-expansion-panels inset focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>收款明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_fee" :items="fee_list" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>退款明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_fee" :items="fee_cancel_list" :items-per-page="10" class="elevation-2"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>门诊结算明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_fee_settle" :items="fee_settle_list" :items-per-page="10" class="elevation-3"></v-data-table>
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
    tdatetype: "schedule",
    tpid: "",
    headers_fee: [
      {
        text: "门诊号",
        align: "left",
        sortable: true,
        value: "pid"
      },
      { text: "姓名", value: "patient_name" },
      { text: "身份类别", value: "patient_type" },
      { text: "就诊类别", value: "reg_type" },
      { text: "收费项目", value: "item_name" },
      { text: "单位", value: "units" },
      { text: "定价", value: "ref_price" },
      { text: "实收单价", value: "real_price" },
      { text: "数量", value: "quantity" },
      { text: "天数", value: "days" },
      { text: "金额", value: "item_sum" },
      { text: "医保编码", value: "mi_code" },
      { text: "申请时间", value: "cal_time" },
      { text: "申请医生", value: "cal_opcode" },
      { text: "收费时间", value: "cashtime" },
      { text: "收款员", value: "cash_opcode" },
      { text: "执行时间", value: "exec_time" },
      { text: "执行人", value: "exec_opcode" },
      { text: "处方状态", value: "presc_status" },
      { text: "医技科室", value: "disp_dept" },
      { text: "处方号", value: "presc_no" },
      { text: "单次结算号", value: "receipt_number" },
      { text: "退款标记", value: "cancel_flag" }
    ],
    headers_fee_settle: [
      {
        text: "门诊号",
        align: "left",
        sortable: true,
        value: "pid"
      },
      { text: "姓名", value: "patient_name" },
      { text: "患者身份", value: "patient_type " },
      { text: "单次结算号", value: "receipt_nmb" },
      { text: "结算时间", value: "settle_time" },
      { text: "操作员", value: "opcode" },
      { text: "总费用", value: "all_sum" },
      { text: "现金支付", value: "cash_sum" },
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
      { text: "退费标记", value: "cash_cancel" }
    ],
    fee_list: [],
    fee_cancel_list: [],
    fee_settle_list: []
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
    sch_fee() {
      console.log("开始查询门诊费用明细");
      let tinstr = this.tdatetype + "|" + process.env.VUE_APP_HSP_CODE + "|" + this.topcode + "|" + this.pid;
      let turl = process.env.VUE_APP_REG_URL + "/searchfeemulti/feeshifts/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      console.log("turl=" + turl);
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退款明细data=" + JSON.stringify(data))
        if (data.resultCode == "0") {
          let tlist = Array.of();
          tlist = data.outdata.split("|");
          console.log("-----tlist[0]=" + tlist[0]);
          this.fee_list = JSON.parse(tlist[0]);
          console.log("-----tlist[1]=" + tlist[1]);
          this.fee_cancel_list = JSON.parse(tlist[1]);
          this.fee_settle_list = JSON.parse(tlist[2]);
          //console.log("查询退款明细data2");
        }
      });
    }
    // ---------------------end methods----------------
  }
};
</script>
