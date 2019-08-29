<template>
  <v-container class="grey lighten-5">
    <v-card class="mx-auto" max-width="99%" min-width="100%">
      <v-card-text>
        <v-layout row wrap>
          <v-flex d-flex>
            &emsp;&emsp;
            <v-text-field v-model="out_reg.pid" label="门诊号"></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.patientName"
              label="姓名"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.regType"
              label="就诊类别"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.patientType"
              label="患者类别"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.miPaccLeft"
              label="医保卡余额"
              disabled
            ></v-text-field
            >&emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.outDiag"
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
              v-model="out_reg.payShould"
              label="应收金额"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payCash"
              label="现金支付"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payNfc"
              label="移动支付"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payPacc"
              label="医保帐户"
              disabled
            ></v-text-field>
            &emsp;&emsp;
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.payFund"
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
         <v-radio-group row v-model="out_reg.payType">
          <v-flex d-flex><v-radio key="cash" label="现金" value="cash"></v-radio></v-flex>
          <v-flex d-flex><v-radio key="wechat" label="微信" value="wechat"></v-radio></v-flex>
          <v-flex d-flex><v-radio key="alipay" label="支付宝" value="alipay"></v-radio></v-flex>
      </v-radio-group>
    
        <v-flex d-flex><v-btn id="snap" :disabled="!valid" color="success">预  结  算</v-btn>
        <v-btn depressed :disabled="!valid" color="success" @click="validate">生成支付码</v-btn>
        <v-btn :disabled="!valid" color="success" @click="validate">确认收款</v-btn>      
        <v-btn :disabled="!valid" color="success" @click="validate">打印收据</v-btn>
        <v-btn :disabled="!valid" color="success" @click="validate">新增处方</v-btn>
        <v-btn :disabled="!valid" color="success" @click="validate">查询历史</v-btn>
        <v-btn :disabled="!valid" color="warning" @click="validate">下一患者</v-btn>
        <v-spacer></v-spacer></v-flex>
        </v-layout>
      </v-card-actions>
    </v-card>
    <!-- -------------------------费用明细栏 --------------------------------------------- -->
    <v-data-table
      :headers="headers"
      :items="desserts"
      :items-per-page="5"
      class="elevation-1"
    ></v-data-table>
  </v-container>
</template>

<script>
export default {
  data: () => ({
    valid: true,
    nameRules: [
      v => !!v || "姓名不能为空",
      v => (v && v.length >= 2) || "姓名长度不能少于2个汉字"
    ],
    out_reg: {
      seq: 0,
      hspCode: process.env.VUE_APP_HSP_CODE,
      pid: "", //门诊号
      patientName: "",
      patientType: "",
      regType: "",
      prescNmb: "",
      outDiag: "", //门诊诊断
      miPaccLeft: 0.0, //医保卡余额
      addr: "", //住址
      payShould: 0.0, //应收金额
      payCash: 0.0, //实收现金
      payNfc: 0.0, //移动支付
      payPacc: 0.0, //医保帐户
      payFund: 0.0, //医保统筹
      payType: "cash"
    },
    headers: [
      {
        text: "项目名称",
        align: "left",
        sortable: false,
        value: "name"
      },
      { text: "单价", value: "calories" },
      { text: "数量", value: "fat" },
      { text: "天数", value: "carbs" },
      { text: "开具时间", value: "protein" },
      { text: "医师", value: "iron" }
    ],
    desserts: [
      {
        name: "Frozen Yogurt",
        calories: 159,
        fat: 6.0,
        carbs: 24,
        protein: 4.0,
        iron: "1%"
      },
      {
        name: "Ice cream sandwich",
        calories: 237,
        fat: 9.0,
        carbs: 37,
        protein: 4.3,
        iron: "1%"
      },
      {
        name: "Eclair",
        calories: 262,
        fat: 16.0,
        carbs: 23,
        protein: 6.0,
        iron: "7%"
      },
      {
        name: "Cupcake",
        calories: 305,
        fat: 3.7,
        carbs: 67,
        protein: 4.3,
        iron: "8%"
      },
      {
        name: "Gingerbread",
        calories: 356,
        fat: 16.0,
        carbs: 49,
        protein: 3.9,
        iron: "16%"
      },
      {
        name: "Jelly bean",
        calories: 375,
        fat: 0.0,
        carbs: 94,
        protein: 0.0,
        iron: "0%"
      },
      {
        name: "Lollipop",
        calories: 392,
        fat: 0.2,
        carbs: 98,
        protein: 0,
        iron: "2%"
      },
      {
        name: "Honeycomb",
        calories: 408,
        fat: 3.2,
        carbs: 87,
        protein: 6.5,
        iron: "45%"
      },
      {
        name: "Donut",
        calories: 452,
        fat: 25.0,
        carbs: 51,
        protein: 4.9,
        iron: "22%"
      },
      {
        name: "KitKat",
        calories: 518,
        fat: 26.0,
        carbs: 65,
        protein: 7,
        iron: "6%"
      }
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
    }
    // ---------------------end methods----------------
  }
};
</script>
