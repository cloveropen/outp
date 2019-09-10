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
              ><v-radio key="wechat" label="本班次" value="schedule"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="alipay" label="昨天" value="yesterday"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="alipay" label="三天前" value="3daysbf"></v-radio
            ></v-flex>
            <v-flex d-flex
              ><v-radio key="alipay" label="一周前" value="weekbf"></v-radio
            ></v-flex>
          </v-radio-group>
       
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="topcode"
              label="操作员号(选填)"
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="tpid"
              label="门诊号(选填)"
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
              :disabled="!valid"
              color="success"
              @click="validate"
              >查询</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >导出</v-btn
            >
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>   
<v-data-table
            :headers="headers"
            :items="fee_details"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
    <v-expansion-panels inset focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple
          >退款明细</v-expansion-panel-header
        >
        <v-expansion-panel-content>
          <v-data-table
            :headers="headers"
            :items="fee_details"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    topcode: "",    
    tdatetype: "schedule",   
    tpid: "",
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
    ]
  }),

  created() {
    console.log("created");
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
    pidChanged(e) {
      console.log("pid=" + e);
      //门诊号规则:患者主索引8位，门诊号为11位，门诊号=主索引编号+3位数字，后3位数字为挂号的序号
      let tpid = e.trim();
      let _this = this;
      if (tpid.length == 8 || tpid.length == 11) {
        let thsp_code = process.env.VUE_APP_HSP_CODE;
        fetch(
          process.env.VUE_APP_REG_URL +
            "/searchoutregcash/" +
            tpid +
            "/" +
            thsp_code,
          {
            method: "get",
            headers: {
              Accept: "text/html",
              "Content-Type": "application/json"
            }
          }
        )
          .then(function(response) {
            if (response.ok) {
              //window.alert("---ok=");
            } else {
              window.alert("查询患者信息失败error" + response.text);
            }
            return response.json();
          })
          .then(function(data) {
            console.log("data=" + JSON.stringify(data));
            let tresultCode = data.resultCode;
            //window.alert("tresultCode="+tresultCode)
            if (tresultCode === "0") {
              _this.out_reg = JSON.parse(data.outdata);
              console.log(" this.out_reg=" + JSON.stringify(_this.out_reg));
              console.log(
                " this.out_reg.patientName=" + _this.out_reg.patientName
              );
              //return toutreg;
            } else {
              window.alert("查询患者主索引信息失败1" + data.errorMsg);
            }
          })
          .catch(function(err) {
            window.alert("查询患者主索引信息查询error=" + err);
          });
      } else {
        //window.alert("请输入正确的门诊号或患者主索引号");
        return;
      }
      console.log(" this.out_reg=" + JSON.stringify(_this.out_reg));
      return _this.out_reg;
    },
    getfeedetail(e) {
      console.log("getfeedetail pid=" + e);
      //门诊号规则:患者主索引8位，门诊号为11位，门诊号=主索引编号+3位数字，后3位数字为挂号的序号
      let tpid = e.trim();
      let _this = this;
      if (tpid.length == 8 || tpid.length == 11) {
        let thsp_code = process.env.VUE_APP_HSP_CODE;
        fetch(
          process.env.VUE_APP_REG_URL +
            "/searchfeedetail/" +
            tpid +
            "/9/" +
            thsp_code,
          {
            method: "get",
            headers: {
              Accept: "text/html",
              "Content-Type": "application/json"
            }
          }
        )
          .then(function(response) {
            if (response.ok) {
              //window.alert("---ok=");
            } else {
              window.alert("查询患者信息失败error" + response.text);
            }
            return response.json();
          })
          .then(function(data) {
            console.log("data=" + JSON.stringify(data));
            let tresultCode = data.resultCode;
            //window.alert("tresultCode="+tresultCode)
            if (tresultCode === "0") {
              _this.fee_details = JSON.parse(data.outdata);
              console.log(" this.out_reg=" + JSON.stringify(_this.fee_details));
            } else {
              window.alert("查询患者主索引信息失败1" + data.errorMsg);
            }
          })
          .catch(function(err) {
            window.alert("查询患者主索引信息查询error=" + err);
          });
      } else {
        //window.alert("请输入正确的门诊号或患者主索引号");
        return;
      }
      console.log(" this.out_reg=" + JSON.stringify(_this.out_reg));
      return _this.out_reg;
    }
    // ---------------------end methods----------------
  }
};
</script>
