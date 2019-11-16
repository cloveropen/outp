<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="topcode" label="操作员号" required></v-text-field>&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="tpasswd" :rules="passRules" label="密码" required type="password"></v-text-field>&emsp;&emsp;
          </v-flex>

          <v-flex d-flex>
            <v-btn color="success" @click="loginChkReceipt">验证</v-btn>
            &emsp;&emsp;
          </v-flex>

          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="topname" label="姓名" readonly></v-text-field>&emsp;&emsp;
          </v-flex>
        </v-layout>
      </v-card-text>

      <v-card-actions class="justify-center">
        <v-layout row wrap no-gutters>
          <v-flex d-flex><v-spacer></v-spacer></v-flex>
          <v-flex d-flex>
            <v-btn depressed :disabled="!valid" color="success" >确认修改</v-btn>
            <v-btn :disabled="!valid" color="success" @click="schinvoice_rec">查询修改历史</v-btn>
            <v-spacer></v-spacer
          ></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <v-row no-gutters>
      <v-col cols="5" sm="5">
        <v-card class="pa-5" outlined>
          <v-list shaped>
            <v-subheader>修改前</v-subheader>
            <v-list-item-group color="primary">
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-account</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>挂号收据号:{{ invoice_op.invoice_nmb1 }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-account</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>收款收据号:{{ invoice_op.invoice_nmb2 }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-account</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>预交金收据号:{{ invoice_op.invoice_nmb3 }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-account</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>出院结算收据号:{{ invoice_op.invoice_nmb4 }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-account</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>移动支付收款收据号:{{ invoice_op.invoice_nmb5 }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-account</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>移动支付预交金收据号:{{ invoice_op.invoice_nmb6 }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-flag</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>
                    <v-select v-model="treason" :items="reasons" menu-props="auto" label="更改原因" hide-details single-line required></v-select>
                  </v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </v-list-item-group>
          </v-list>
        </v-card>
      </v-col>
      <v-col cols="7" sm="7">
        <v-card class="pa-5" outlined>
          <v-list shaped>
            <v-subheader>修改后</v-subheader>
            <v-list-item-group color="primary">
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-clock</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>
                    <v-text-field v-model="tnew_invoice_nmb1" label="挂号收据号"></v-text-field>
                  </v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-clock</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title> <v-text-field v-model="tnew_invoice_nmb2" label="收款收据号"></v-text-field></v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-clock</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title> <v-text-field v-model="tnew_invoice_nmb3" label="预交金收据号"></v-text-field></v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-clock</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title> <v-text-field v-model="tnew_invoice_nmb4" label="出院结算收据号"></v-text-field></v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-clock</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title> <v-text-field v-model="tnew_invoice_nmb5" label="移动支付收款收据号"></v-text-field></v-list-item-title>
                </v-list-item-content>
              </v-list-item>
              <v-list-item>
                <v-list-item-icon>
                  <v-icon>mdi-clock</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title><v-text-field v-model="tnew_invoice_nmb6" label="移动支付预交金收据号"></v-text-field></v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </v-list-item-group>
          </v-list>
        </v-card>
      </v-col>
    </v-row>

    <v-expansion-panels inset focusable>
      <v-expansion-panel>
        <v-expansion-panel-header ripple>收据号修改历史</v-expansion-panel-header>
        <v-expansion-panel-content>
          <v-data-table :headers="headers_invoice_rec" :items="invoice_rec_list" :items-per-page="10" class="elevation-1"></v-data-table>
        </v-expansion-panel-content>
      </v-expansion-panel>
    </v-expansion-panels>
  </v-container>
</template>

<script>
import { fetch_cash_async, post_cash_async, get_regopcode } from "../scripts/outcash.js";
export default {
  data: () => ({
    topcode: "",
    tpasswd: "",
    passRules: [v => !!v || "用户密码不能为空", v => v.length >= 6 || "用户密码长度必须超过6个字符"],
    topname: "",
    valid: false,
    invoice_op: {
      seq: 0,
      hsp_code: "",
      opcode: "",
      opname: "",
      optime: new Date(), 
      invoice_nmb1: "", 
      invoice_nmb2: "",
      invoice_nmb3: "",
      invoice_nmb4: "",
      invoice_nmb5: "",
      invoice_nmb6: ""
    },
    treason: "",
    tnew_invoice_nmb1: "",
    tnew_invoice_nmb2: "",
    tnew_invoice_nmb3: "",
    tnew_invoice_nmb4: "",
    tnew_invoice_nmb5: "",
    tnew_invoice_nmb6: "",
    headers_invoice_rec: [
      {
        text: "操作员编码",
        align: "left",
        sortable: false,
        value: "opcode"
      },
      { text: "操作员姓名", value: "opname" },
      { text: "修改时间", value: "optime" },
      { text: "修改人", value: "modi_opcode" },
      { text: "修改原因", value: "reason" },
      { text: "改前挂号", value: "invoice_nmb1" },
      { text: "改前收款", value: "invoice_nmb2" },
      { text: "改前预交金", value: "invoice_nmb3" },
      { text: "改前出院结算", value: "invoice_nmb4" },
      { text: "改前补打移动收款", value: "invoice_nmb5" },
      { text: "改前补打移动预交金", value: "invoice_nmb6" },
      { text: "改后挂号", value: "new_invoice_nmb1" },
      { text: "改后收款", value: "new_invoice_nmb2" },
      { text: "改后预交金", value: "new_invoice_nmb3" },
      { text: "改后出院结算", value: "new_invoice_nmb4" },
      { text: "改后补打移动收款", value: "new_invoice_nmb5" },
      { text: "改后补打移动预交金", value: "new_invoice_nmb6" }
    ],
    invoice_rec_list: [],
    reasons: ["新换收据", "打印机夹纸", "打印机空走", "设置错误", "其他原因"]
  }),
  methods: {
    loginChkReceipt() {
      let sel = this;
      let tinstr = '{"opid":"' + this.topcode + '","opname":"","oppass":"' + this.tpasswd + '","opstatus":""}';
      post_cash_async(process.env.VUE_APP_LOGIN_URL, tinstr).then(data => {
        let topstatus = data.opstatus;
        if (topstatus === "200") {
          localStorage.setItem("user", JSON.stringify(data));
          //sel.$parent.$router.push({ path: "/" });
          // 提交保存登录凭证数据
          let thsp_code = process.env.VUE_APP_HSP_CODE;
          data.hsp_code = thsp_code;
          var date = new Date();
          data.valid_time = date.toUTCString();
          // -----------------------------------------------------------------------------------------------
          post_cash_async(process.env.VUE_APP_LOGINREC_URL + "/savetgc", JSON.stringify(data)).then(data => {
            console.log("用户信息保存成功=" + JSON.stringify(data));
            // --查询操作员姓名和交班的开始时间,截止时间默认是当前时间
            sel.tgc = get_regopcode().split("|")[1];            
            let turl = process.env.VUE_APP_REG_URL + "/searchinvoiceop/" + thsp_code + 
              "/" + sel.topcode + "/" + sel.tgc;
          fetch_cash_async(turl, "get").then(data => {
              console.log("data=" + JSON.stringify(data));
              if (data.resultCode === "0") {
                let toutdata = JSON.parse(data.outdata);
                sel.valid = true;
                sel.topname = toutdata.opname;
                sel.invoice_op = toutdata;
                sel.tnew_invoice_nmb1 = toutdata.invoice_nmb1;
                sel.tnew_invoice_nmb2 = toutdata.invoice_nmb2;
                sel.tnew_invoice_nmb3 = toutdata.invoice_nmb3;
                sel.tnew_invoice_nmb4 = toutdata.invoice_nmb4;
                sel.tnew_invoice_nmb5 = toutdata.invoice_nmb5;
                sel.tnew_invoice_nmb6 = toutdata.invoice_nmb6;
              } else {
                window.alert("查询失败" + data.errorMsg);
              }
           });                
          });
          
          // ------------------------------------------------------------------------------------------------
        }
      });
    },
    // ----------------查询发票号修改历史记录----------------------------------------------------
    schinvoice_rec() {
        this.tgc = get_regopcode().split("|")[1]; 
        let tbeg = this.getDateStr(-365)+' 00:00:00';        
        let tend = this.setNowFormatDate(new Date());
        let tinstr = process.env.VUE_APP_HSP_CODE + "|" + tbeg + "|" +tend;        
        let turl = process.env.VUE_APP_REG_URL + "/searchinvoicerecmulti/opcode/" + tinstr + 
              "/" + this.topcode + "/" + this.tgc;
        fetch_cash_async(turl, "get").then(data => {
          console.log("-----------data="+JSON.stringify(data))
          this.invoice_rec_list = data.outdata;
        });
    },
    setNowFormatDate(tdate) {
      let date = tdate;
      let month = (date.getMonth() + 1).toString().padStart(2,'0');
      let strDate = date.getDate().toString().padStart(2,'0');
      //时间格式yyyy-MM-dd HH:MM:SS
      return `${date.getFullYear()}-${month}-${strDate} ${this.getCurrentTime()}`;
    },
    getCurrentTime() {
      let date = new Date();
      //时间格式HH:MM:SS
      return `${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`;
    },
    getDateStr(addDayCount) { 
      var dd = new Date();
      dd.setDate(dd.getDate()+addDayCount);//获取AddDayCount天后的日期
      var y = dd.getFullYear(); 
      var m = (dd.getMonth()+1)<10?"0"+(dd.getMonth()+1):(dd.getMonth()+1);//获取当前月份的日期，不足10补0
      var d = dd.getDate()<10?"0"+dd.getDate():dd.getDate();//获取当前几号，不足10补0
      return y+"-"+m+"-"+d; 
    }
    // ---------------------end methods----------------
  }
};
</script>