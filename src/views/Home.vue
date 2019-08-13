<template>
  <v-app id="inspire">
    <v-navigation-drawer
       v-model="drawer"
        :clipped="$vuetify.breakpoint.lgAndUp"
         app>
      <v-list dense>
        <template v-for="item in items">
          <v-layout v-if="item.heading" :key="item.heading" align-center>
            <v-flex xs6>
              <v-subheader v-if="item.heading">{{ item.heading }}</v-subheader>
            </v-flex>
            <v-flex xs6 class="text-center">
              <a href="#!" class="body-2 black--text">EDIT</a>
            </v-flex>
          </v-layout>
          <v-list-group
            v-else-if="item.children"
            :key="item.text"
            v-model="item.model"
            :prepend-icon="item.model ? item.icon : item['icon-alt']"
            append-icon
          >
            <template v-slot:activator>
              <v-list-item>
                <v-list-item-content>
                  <v-list-item-title>{{ item.text }}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
            <v-list-item v-for="(child, i) in item.children" :key="i" @click="clickMenu(child.id)">
              <v-list-item-action v-if="child.icon">
                <v-icon>{{ child.icon }}</v-icon>
              </v-list-item-action>
              <v-list-item-content>
                <v-list-item-title>{{ child.text }}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list-group>
          <v-list-item v-else :key="item.text" @click="clickMenu(item.id)">
            <v-list-item-action>
              <v-icon>{{ item.icon }}</v-icon>
            </v-list-item-action>
            <v-list-item-content>
              <v-list-item-title>{{ item.text }}</v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </template>
      </v-list>
    </v-navigation-drawer>

    <v-app-bar :clipped-left="$vuetify.breakpoint.lgAndUp" app color="blue darken-3" dark>
      <v-toolbar-title style="width: 300px" class="ml-0 pl-4">
        <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
        <span class="hidden-sm-and-down">门急诊管理</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-tooltip right>
        <template v-slot:activator="{ on }">
          <v-btn icon to="/about" v-on="on">
            <v-icon>thumb_up_alt</v-icon>
          </v-btn>
        </template>
        <span>帮助手册</span>
      </v-tooltip>
      <v-btn icon to="/">
        <v-icon>notifications</v-icon>
      </v-btn>
      <v-btn icon large @click="selectSource">
        <v-avatar size="32px" item>
          <v-img :src="require('../assets/logo.svg')" alt="苜蓿草科技"></v-img>
        </v-avatar>
      </v-btn>
    </v-app-bar>
    <!--<v-content> -->
    <v-container fluid fill-height>
      <v-layout justify-start>
        <v-img :src="require('../assets/main_bg.jpg')" />
      </v-layout>
    </v-container>
    <!-- </v-content> -->
    <v-tooltip right>
      <template v-slot:activator="{ on }">
        <v-btn bottom color="pink" dark fab fixed right @click="clickMenu('logout')" v-on="on">
          <v-icon>add</v-icon>
        </v-btn>
      </template>
      <span>退出登录</span>
    </v-tooltip>
  </v-app>
</template>

<script>
export default {
  props: {
    source: String
  },
  data: () => ({
    dialog: false,
    drawer: null,
    items: [
      { icon: "contacts", text: "门诊挂号", id: "out_reg" },
      { icon: "history", text: "划价收款", id: "out_cash" },
      { icon: "content_copy", text: "交班结算", id: "out_chk" },
      { icon: "keyboard", text: "发票号管理", id: "out_receipt" },
      {
        icon: "keyboard_arrow_up",
        "icon-alt": "keyboard_arrow_down",
        text: "查询与统计",
        model: true,
        children: [
          { text: "挂号明细", id: "detail_reg" },
          { text: "收款明细", id: "detail_cash" },
          { text: "交班结算", id: "detail_chk" },
          { text: "退号退款", id: "detail_undo" },
          { text: "操作日志", id: "detail_op" }
        ]
      },
      {
        icon: "settings",
        "icon-alt": "keyboard_arrow_down",
        text: "管理与维护",
        model: false,
        children: [
          { text: "词典维护" },
          { text: "数据分析" },
          { text: "收据管理" }
        ]
      },
      { icon: "help", text: "退出登录", id: "logout" }
    ]
  }),
  methods: {
    clickMenu(tstr) {
      window.alert("点击=" + tstr);
      if (tstr === "logout") {
        localStorage.removeItem("user");
        this.$router.push({ path: "/login" });
      }
    },

    selectSource() {
      window.location.href = "http://www.cloveropen.com";
    }
  }
};
</script>
