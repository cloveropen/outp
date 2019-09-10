<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="topcode"
              label="管理员号"
              required
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="passwd"
              :rules="passRules"
              label="密码"
              required
              type="password"
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>

          <v-flex d-flex>
            <v-btn color="success" @click="loginSubmit">验证</v-btn>
            &emsp;&emsp;
          </v-flex>

          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="topname" label="姓名" readonly></v-text-field
            >&emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>
      <v-row no-gutters>
        <v-col cols="5" sm="5">
          <v-card class="pa-5" outlined>
            <v-list shaped>
              <v-list-item-group color="primary">
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-flag</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title>
                      <v-select
                        v-model="invoice_rec.reason"
                        :items="reasons"
                        menu-props="auto"
                        label="领用人"
                        hide-details
                        single-line
                        required
                      ></v-select>
                    </v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </v-list-item-group>
            </v-list>
            <v-list shaped>
              <v-subheader>上次领用</v-subheader>
              <v-list-item-group color="primary">
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title
                      >挂号收据号:{{
                        invoice_rec.invoice_nmb1
                      }}</v-list-item-title
                    >
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title
                      >收款收据号:{{
                        invoice_rec.invoice_nmb2
                      }}</v-list-item-title
                    >
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title
                      >预交金收据号:{{
                        invoice_rec.invoice_nmb3
                      }}</v-list-item-title
                    >
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title
                      >出院结算收据号:{{
                        invoice_rec.invoice_nmb4
                      }}</v-list-item-title
                    >
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title
                      >移动支付收款收据号:{{
                        invoice_rec.invoice_nmb5
                      }}</v-list-item-title
                    >
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-account</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title
                      >移动支付预交金收据号:{{
                        invoice_rec.invoice_nmb6
                      }}</v-list-item-title
                    >
                  </v-list-item-content>
                </v-list-item>
              </v-list-item-group>
            </v-list>
          </v-card>
        </v-col>
        <v-col cols="7" sm="7">
          <v-card class="pa-5" outlined>
            <v-list shaped>
              <v-subheader>本次领用</v-subheader>
              <v-list-item-group color="primary">
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-clock</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title>
                      <v-text-field
                        v-model="invoice_rec.new_invoice_nmb1"
                        label="挂号收据号"
                      ></v-text-field>
                    </v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-clock</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title>
                      <v-text-field
                        v-model="invoice_rec.new_invoice_nmb2"
                        label="收款收据号"
                      ></v-text-field
                    ></v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-clock</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title>
                      <v-text-field
                        v-model="invoice_rec.new_invoice_nmb3"
                        label="预交金收据号"
                      ></v-text-field
                    ></v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-clock</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title>
                      <v-text-field
                        v-model="invoice_rec.new_invoice_nmb4"
                        label="出院结算收据号"
                      ></v-text-field
                    ></v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-clock</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title>
                      <v-text-field
                        v-model="invoice_rec.new_invoice_nmb5"
                        label="移动支付收款收据号"
                      ></v-text-field
                    ></v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-clock</v-icon>
                  </v-list-item-icon>
                  <v-list-item-content>
                    <v-list-item-title
                      ><v-text-field
                        v-model="invoice_rec.new_invoice_nmb6"
                        label="移动支付预交金收据号"
                      ></v-text-field
                    ></v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </v-list-item-group>
            </v-list>
          </v-card>
        </v-col>
      </v-row>
      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex>
            <v-btn
              depressed
              :disabled="!valid"
              color="success"
              @click="validate"
              >确认发票领用</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >导出明细</v-btn
            >
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <v-expansion-panels inset focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple
          ><b>发票领用记录表</b></v-expansion-panel-header
        >
        <v-expansion-panel-content>
          <!-- -------------------------发票领用记录表 --------------------------------------------- -->
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
    tpasswd: "",
    passRules: [
      v => !!v || "用户密码不能为空",
      v => v.length >= 6 || "用户密码长度必须超过6个字符"
    ],
    topname: "",
    invoice_rec: {
      opcode: "",
      opname: "",
      reason: "",
      invoice_nmb1: "",
      invoice_nmb2: "",
      invoice_nmb3: "",
      invoice_nmb4: "",
      invoice_nmb5: "",
      invoice_nmb6: "",
      new_invoice_nmb1: "",
      new_invoice_nmb2: "",
      new_invoice_nmb3: "",
      new_invoice_nmb4: "",
      new_invoice_nmb5: "",
      new_invoice_nmb6: ""
    },
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
    fee_details: []
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
