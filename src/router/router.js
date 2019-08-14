import Vue from "vue";
import Router from "vue-router";
import Home from "../views/Home.vue";

Vue.use(Router);

export const router = new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/",
      name: "home",
      component: Home
    },
    {
      path: "/about",
      name: "about",
      // route level code-splitting
      // this generates a separate chunk (about.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () =>
        import(/* webpackChunkName: "about" */ "../views/About.vue")
    },
    {
      path: "/outreg",
      name: "outreg",
      component: () =>
        import(/* webpackChunkName: "outreg" */ "../views/Outreg.vue")
    },
    {
      path: "/outcash",
      name: "outcash",
      component: () =>
        import(/* webpackChunkName: "outreg" */ "../views/Outcash.vue")
    },
    {
      path: "/outchk",
      name: "outchk",
      component: () =>
        import(/* webpackChunkName: "outchk" */ "../views/Outchk.vue")
    },
    {
      path: "/outreceipt",
      name: "outreceipt",
      component: () =>
        import(/* webpackChunkName: "outreceipt" */ "../views/Outreceipt.vue")
    },
    {
      path: "/detailreg",
      name: "detailreg",
      component: () =>
        import(/* webpackChunkName: "detailreg" */ "../views/Detailreg.vue")
    },
    {
      path: "/detailcash",
      name: "detailcash",
      component: () =>
        import(/* webpackChunkName: "detailcash" */ "../views/Detailcash.vue")
    },
    {
      path: "/detailchk",
      name: "detailchk",
      component: () =>
        import(/* webpackChunkName: "detailchk" */ "../views/Detailchk.vue")
    },
    {
      path: "/detailundo",
      name: "detailundo",
      component: () =>
        import(/* webpackChunkName: "detailundo" */ "../views/Detailundo.vue")
    },
    {
      path: "/detailop",
      name: "detailop",
      component: () =>
        import(/* webpackChunkName: "detailop" */ "../views/Detailop.vue")
    },
    {
      path: "/mgdict",
      name: "mgdict",
      component: () =>
        import(/* webpackChunkName: "mgdict" */ "../views/Mgdict.vue")
    },
    {
      path: "/mganalyse",
      name: "mganalyse",
      component: () =>
        import(/* webpackChunkName: "mganalyse" */ "../views/Mganalyse.vue")
    },
    {
      path: "/mginvoice",
      name: "mginvoice",
      component: () =>
        import(/* webpackChunkName: "mginvoice" */ "../views/Mginvoice.vue")
    },
    {
      path: "/login",
      name: "login",
      component: () =>
        import(/* webpackChunkName: "login" */ "../views/Login.vue")
    }
  ]
});

router.beforeEach((to, from, next) => {
  // redirect to login page if not logged in and trying to access a restricted page
  const publicPages = ["/login", "/register"];
  const authRequired = !publicPages.includes(to.path);
  const loggedIn = localStorage.getItem("user");
  // console.log("authRequired=" + authRequired + " loggedIn=" + loggedIn);
  if (authRequired && !loggedIn) {
    return next("/login");
  }

  next();
});
