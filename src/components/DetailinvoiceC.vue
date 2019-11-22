<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-radio-group row v-model="tdatetype">
            <v-flex d-flex><v-radio key="today" label="今天" value="today"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="schedule_last" label="上班次" value="schedule_last"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="yesterday" label="昨天" value="yesterday"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="3daysbf" label="三天内" value="3daysbf"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="weekbf" label="一周内" value="weekbf"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="monthbf" label="一月内" value="monthbf"></v-radio></v-flex>
          </v-radio-group>

          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="topcode" label="操作员号" readonly required></v-text-field>&emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex>
            <v-btn depressed color="success" @click="sch_invoice">查询</v-btn>
            <v-btn color="success" @click="reset">导出汇总</v-btn>
            <v-btn color="success" @click="reset">导出明细</v-btn>
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <v-expansion-panels popout focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>打印挂号收据明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_outreg_prn" :items="out_reg_prn_list" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>打印收款收据明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_out_cash_prn" :items="out_cash_prn_list" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>打印出院结算收据明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_discharge_prn" :items="discharge_prn_list" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>打印预交金收据明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_deposit_prn" :items="deposit_prn_list" :items-per-page="10" class="elevation-1"></v-data-table>
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
    headers_outreg_prn: [
      {
        text: "门诊号",
        align: "left",
        sortable: true,
        value: "pid"
      },
      { text: "姓名", value: "patient_name" },
      { text: "号类", value: "reg_type" },
      { text: "科室", value: "dept" },
      { text: "医师", value: "doctor" },
      { text: "费别", value: "pay_type" },
      { text: "挂号费", value: "reg_price" },
      { text: "诊察费", value: "check_price" },
      { text: "现金", value: "pay_cash" },
      { text: "个人帐户", value: "pay_pacc" },
      { text: "医保统筹", value: "pay_fund" },
      { text: "农合统筹", value: "fund_nh_sum" },
      { text: "移动支付", value: "pay_nfc" },
      { text: "挂号员", value: "reg_opcode" },
      { text: "挂号时间", value: "reg_time" },
      { text: "票据号", value: "invoice_nmb" },
      { text: "就诊地点", value: "location" },
      { text: "候诊时段", value: "wait_period" },
      { text: "状态", value: "prn_status" }
    ],
    headers_out_cash_prn: [
      {
        text: "门诊号",
        align: "left",
        sortable: true,
        value: "pid"
      },
      { text: "姓名", value: "patient_name" },
      { text: "挂号类别", value: "reg_type" },
      { text: "患者类型", value: "patient_type" },
      { text: "总费用", value: "pay_sum" },
      { text: "收款时间", value: "cash_time" },
      { text: "收款员", value: "cash_opcode" },
      { text: "现金", value: "pay_cash" },
      { text: "统筹支付", value: "pay_fund" },
      { text: "医保帐户", value: "pay_pacc" },
      { text: "低保支付", value: "pay_fund_db" },
      { text: "大额支付", value: "pay_fund_large" },
      { text: "微信支付", value: "pay_wechat" },
      { text: "支付宝", value: "pay_alipay" },
      { text: "银行卡", value: "pay_unionpay" },
      { text: "公务员补助", value: "pay_fund_gwy" },
      { text: "离干统筹", value: "pay_lixiu" },
      { text: "票据号", value: "invoice_nmb" },
      { text: "状态", value: "prn_status" }
    ],
    headers_discharge_prn: [
      {
        text: "住院号",
        align: "left",
        sortable: true,
        value: "pid"
      },
      { text: "姓名", value: "patient_name" },
      { text: "患者类型", value: "patient_type" },
      { text: "住院(医疗)类别", value: "in_type" },
      { text: "打印人", value: "opcode" },
      { text: "打印时间", value: "prn_time" },
      { text: "总费用", value: "all_sum" },
      { text: "打印状态", value: "prn_status" }
    ],
    headers_deposit_prn: [
      {
        text: "住院号",
        align: "left",
        sortable: true,
        value: "pid"
      },
      { text: "姓名", value: "patient_name" },
      { text: "姓名", value: "dept_code" },
      { text: "科室", value: "room" },
      { text: "病床号", value: "bed_nmb" },
      { text: "发票号", value: "invoice_nmb" },
      { text: "交款时间", value: "pay_time" },
      { text: "收款人", value: "opcode" },
      { text: "本次预交", value: "pay_sum" },
      { text: "现金支付", value: "pay_cash" },
      { text: "微信支付", value: "pay_weixin" },
      { text: "支付宝", value: "pay_alipay" },
      { text: "银联支付", value: "pay_union" },
      { text: "支票支付", value: "pay_chk" },
      { text: "其他支付", value: "pay_other" },
      { text: "打印状态", value: "prn_status" },
      { text: "开户行", value: "bank" },
      { text: "帐号", value: "account" }
    ],
    out_reg_prn_list: [],
    out_cash_prn_list: [],
    discharge_prn_list: [],
    deposit_prn_list: []
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
    sch_invoice() {
      console.log("开始查询打印收据信息");
      let tinstr = this.tdatetype + "|" + process.env.VUE_APP_HSP_CODE + "|" + this.topcode;
      let turl = process.env.VUE_APP_REG_URL + "/searchfeemulti/feeprint/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      console.log("turl=" + turl);
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退款明细data=" + JSON.stringify(data))
        if (data.resultCode == "0") {
          let tlist = Array.of();
          tlist = data.outdata.split("|");
          console.log("-----tlist[0]=" + tlist[0]);
          this.out_reg_prn_list = JSON.parse(tlist[0]);
          console.log("-----tlist[1]=" + tlist[1]);
          this.out_cash_prn_list = JSON.parse(tlist[1]);
          this.discharge_prn_list = JSON.parse(tlist[2]);
          this.deposit_prn_list = JSON.parse(tlist[3]);
        }
      });
    }
    // ---------------------end methods----------------
  }
};
</script>