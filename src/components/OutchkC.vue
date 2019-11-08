<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%" justify-center>
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="topcode"
              label="操作员号"
              required
              :disabled="valid"
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field
              v-model="tpasswd"
              :rules="passRules"
              label="密码"
              required
              type="password"
              :disabled="valid"
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>

          <v-flex d-flex>
            <v-btn color="success" :disabled="valid" @click="loginChk">验证</v-btn>
            &emsp;&emsp;
          </v-flex>
          <v-row>
            <v-flex d-flex flex-wrap>
              &emsp;&emsp;
              <v-text-field
                v-model="topname"
                label="操作员姓名"
                disabled
              ></v-text-field
              >&emsp;&emsp;
            </v-flex>
            <br />
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field
                v-model="tbeg"
                label="开始时间"
                disabled
              ></v-text-field
              >&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              <v-text-field
                v-model="tend"
                label="结束时间"
                disabled
              ></v-text-field
              >&emsp;&emsp;
            </v-flex>
          </v-row>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex
            ><v-btn id="snap" :disabled="!valid" color="success">计算</v-btn>
            <v-btn
              depressed
              :disabled="!valid"
              color="success"
              @click="validate"
              >确认交班</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >打印结算表</v-btn
            >
            <v-btn :disabled="!valid" color="success" @click="validate"
              >打印退款明细</v-btn
            >
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <v-expansion-panels inset focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple
          ><b>交班结算表</b></v-expansion-panel-header
        >
        <v-expansion-panel-content>
          <!-- -------------------------交班结算栏 --------------------------------------------- -->
          <v-data-table
            :headers="headers"
            :items="fee_details"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退挂号明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退挂号明细栏 --------------------------------------------- -->
          <v-data-table
            :headers="headers"
            :items="fee_details"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退收款明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退收款明细栏 --------------------------------------------- -->
          <v-data-table
            :headers="headers"
            :items="fee_details"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>退预交金明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------退预交金明细栏 --------------------------------------------- -->
          <v-data-table
            :headers="headers"
            :items="fee_details"
            :items-per-page="10"
            class="elevation-1"
          ></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
      <v-expansion-panel>
        <v-expansion-panel-header>出院结算召回明细</v-expansion-panel-header>
        <v-expansion-panel-content>
          <!-- -------------------------出院结算召回明细 --------------------------------------------- -->
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
import {
  fetch_cash_async,
  post_cash_async,
  get_regopcode
} from "../scripts/outcash.js";
export default {
  data: () => ({
    topcode: "",
    topname: "",
    tpasswd: "",
    tgc: "",
    passRules: [
      v => !!v || "用户密码不能为空",
      v => v.length >= 6 || "用户密码长度必须超过6个字符"
    ],
    tbeg: "",
    tend: "",
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
    valid: false
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
    loginChk() {
      let sel = this;
      let tinstr =
        '{"opid":"' +
        this.topcode +
        '","opname":"","oppass":"' +
        this.tpasswd +
        '","opstatus":""}';
      
      post_cash_async(process.env.VUE_APP_LOGIN_URL,tinstr).then(data => {
        let topstatus = data.opstatus;
        if (topstatus === "200") {
          localStorage.setItem("user", JSON.stringify(data));
          //sel.$parent.$router.push({ path: "/" });
          // 提交保存登录凭证数据
          data.hsp_code = process.env.VUE_APP_HSP_CODE;
          var date = new Date();
          data.valid_time = date.toUTCString();
          // -----------------------------------------------------------------------------------------------
          post_cash_async(process.env.VUE_APP_LOGINREC_URL + "/savetgc",JSON.stringify(data)).then(data => {
            console.log("用户信息保存成功=" + JSON.stringify(data));
            // --查询操作员姓名和交班的开始时间,截止时间默认是当前时间
             sel.tgc = get_regopcode().split("|")[1];
             let thsp_code = process.env.VUE_APP_HSP_CODE;
             let turl = process.env.VUE_APP_REG_URL + "/searchchksumlast/"+thsp_code+"/"+sel.topcode+"/"+sel.tgc;
             fetch_cash_async(turl,"get").then(data => {
               console.log("data=" + JSON.stringify(data));
               if (data.resultCode==="0"){
                 let toutdata = JSON.parse(data.outdata);

                 sel.valid = true;
                 sel.topname = toutdata.opname;
                 sel.tbeg = toutdata.bd;
                 sel.tend = toutdata.ed;
                 console.log("sel.topname="+sel.topname+" this.topname="+this.topname+"|"+toutdata.opname);
               }else{
                 window.alert("查询失败"+data.errorMsg);
               }
             });
            
          });
          // ------------------------------------------------------------------------------------------------
        }
       });
      }
    // ---------------------end methods----------------
  }
};
</script>
