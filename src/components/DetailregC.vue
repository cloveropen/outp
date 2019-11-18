<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-radio-group row v-model="tdatetype">
            <v-flex d-flex><v-radio key="today" label="今天" value="today"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="cycle" label="本班次" value="cycle"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="last_cycle" label="上班次" value="last_cycle"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="yesterday" label="昨天" value="yesterday"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="3daysbf" label="三天前" value="3daysbf"></v-radio></v-flex>
            <v-flex d-flex><v-radio key="weekbf" label="一周前" value="weekbf"></v-radio></v-flex>
          </v-radio-group>

          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="topcode" label="操作员号" readonly></v-text-field>&emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex>
            <v-btn depressed color="success" @click="sch_reg">查询</v-btn>
            <v-btn color="success" @click="validate">导出</v-btn>
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <v-data-table :headers="headers" :items="reg_list" :items-per-page="10" class="elevation-1"></v-data-table>
    <v-expansion-panels inset focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>退号明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers" :items="reg_cancel_list" :items-per-page="10" class="elevation-1"></v-data-table>
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
    headers: [
      {
        text: "门诊号",
        align: "left",
        sortable: true,
        value: "pid"
      },
      { text: "姓名", value: "patient_name" },
      { text: "挂号时间", value: "reg_time" },
      { text: "操作员", value: "reg_opcode" },
      { text: "挂号费", value: "reg_price" },
      { text: "诊察费", value: "check_price" },
      { text: "现金支付", value: "pay_cash" },
      { text: "个人帐户", value: "pay_pacc" },
      { text: "统筹支付", value: "pay_fund" },
      { text: "移动支付", value: "pay_nfc" },
      { text: "收据号", value: "invoice_nmb" },
      { text: "流水号", value: "flow_nmb" },
      { text: "接诊", value: "visit_flag" },
      { text: "退号", value: "reg_cancel" }
    ],
    reg_list: [],
    reg_cancel_list: []
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
    sch_reg() {
      //let topcode = this.topcode;
      // if (topcode==="") get_regopcode().split("|")[0];
      let tinstr = this.tdatetype + "|" + process.env.VUE_APP_HSP_CODE + "|" + this.topcode;
      let turl = process.env.VUE_APP_REG_URL + "/searchoutregmulti/regshifts/" + tinstr + "/" + this.topcode + "/" + this.tgc;
      console.log("turl=" + turl);
      fetch_cash_async(turl, "get").then(data => {
        //console.log("查询退款明细data=" + JSON.stringify(data))
        if (data.resultCode == "0") {
          let tlist = Array.of();
          tlist = data.outdata.split("|");
          console.log("-----tlist[0]=" + tlist[0]);
          this.reg_list = JSON.parse(tlist[0]);
          console.log("-----tlist[1]=" + tlist[1]);
          this.reg_cancel_list = JSON.parse(tlist[1]);

          //console.log("查询退款明细data2");
        }
      });
    }
    // ---------------------end methods----------------
  }
};
</script>
