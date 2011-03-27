var d = true,i = null,k = false;
function m() {
    return function() {
    }
}
function r(b) {
    this.ue("/ping", function() {
        b(d)
    }, function() {
        b(k)
    })
}
function t(b) {
    return b ? b.indexOf("http://localhost:30777") === 0 : k
}
function u(b) {
    if (this.Me(b))if (b.indexOf("session=") === -1 && typeof w.r !== "undefined") {
        b += b.indexOf("?") > -1 ? "&" : "?";
        b += "session=" + $.cookie("user_credentials") + "&user_id=" + w.r + "&callback=?"
    }
    return b
}
function y(b) {
    var c = "";
    if (!b)return b;
    if (!t(b))if (b.indexOf("http://") !== -1 || b.indexOf("https://") !== -1)return b; else c = "http://localhost:30777";
    c += b;
    c = c.replace(/http:\/\/localhost:[^\/]*/, "http://localhost:30777");
    return this.ve(c)
}
function z(b, c) {
    function a(g) {
        g.headers ? B("error calling agent: " + g.headers.status + ":" + g.headers.Ge + " url:  " + e) : B("no response or invalid response from agent. url: " + e)
    }

    var e,f = $.cookie("user_credentials");
    e = b.indexOf("?") == -1 ? "http://localhost:" + this.port + b + "?session=" + f + "&user_id=" + w.r + "&callback=?" : "http://localhost:" + this.port + b + "&session=" + f + "&user_id=" + w.r + "&callback=?";
    $.fc({url:e,g:function(g) {
        g.headers.status == 200 ? c(g.body) : a(g)
    },error:a})
}
zzcontacts = {ready:k,data:[],hf:[],na:{},init:function(b, c, a, e) {
    this.na = $.extend({url:w.a + "/users/" + b + "/contacts.json",Pe:1}, c);
    $.ajax({type:"GET",url:zzcontacts.na.url,dataType:"json",g:function(f) {
        zzcontacts.data = f;
        zzcontacts.ready = d;
        zzcontacts.pd();
        $.isFunction(a) && a()
    },error:function() {
        $.isFunction(e) && e()
    }})
},find:function(b) {
    if (!zzcontacts.ready || !b)return i;
    var c = RegExp(b, "gi");
    b = [];
    for (var a in zzcontacts.data) {
        var e = jQuery.grep(zzcontacts.data[a].Vb, function(f) {
            return f[0].match(c) || f[1].match(c)
        });
        b = b.concat(e)
    }
    return zzcontacts.Gc(b)
},Gc:function(b) {
    var c = [],a;
    for (a in b) {
        var e = b[a],f = e[0];
        e = e[1];
        var g = f;
        if (f.length > 0)f += " &lt;" + e + "&gt;"; else f = g = e;
        c[a] = {id:e,name:f,nf:g}
    }
    return c
},cc:function(b, c, a) {
    if (!b)return i;
    if (b == "local")zzcontacts.Ic(c, a); else {
        var e = k,f = function() {
            e = d;
            $.ajax({dataType:"json",url:w.a + "/" + b + "/contacts/import",g:function(g) {
                zzcontacts.data[b] = {};
                zzcontacts.data[b].Vb = g;
                zzcontacts.data[b].hc = "A moment ago";
                c()
            },error:function(g, j) {
                a("import", j)
            }})
        };
        if (zzcontacts.data[b])f();
        else {
            oauthmanager.Sa(w.a + "/" + b + "/sessions/new", f);
            setTimeout(function() {
                e || a("oauth", "OAuth authorization not possible")
            }, 2E4)
        }
    }
},Ic:function(b, c) {
    r(function(a) {
        if (a) {
            a = y("/contacts/import");
            $.fc({url:a,g:function(e) {
                zzcontacts.data.local = {};
                zzcontacts.data.local.Vb = e.body;
                zzcontacts.data.local.hc = "A moment ago.";
                $.isFunction(b) && b()
            },error:function(e, f) {
                $.isFunction(c) && c("agent", f)
            }})
        } else aa(function() {
            r(function(e) {
                if (e)zzcontacts.cc("local", b, c); else $.isFunction(c) && c("agent", "Please install agent.")
            })
        })
    })
},
    ud:function(b) {
        return zzcontacts.ready && typeof zzcontacts.data[b] != "undefined"
    },pd:function() {
        $(".contacts-btn").each(function(b, c) {
            var a = $(c),e = a.attr("data-service");
            e === "local" && $.Oa.tb === "Mac" && a.find("span").html('<div class="off"></div>Mac Address Book');
            if (zzcontacts.ud(e)) {
                a.find("div").removeClass("off sync error").addClass("on");
                a.attr("title", "Last import on:" + zzcontacts.data[e].hc)
            } else a.attr("title", "Click to import your contacts from this service");
            a.click(function(f) {
                f.preventDefault();
                a.attr("disabled", "disabled");
                a.find("div").removeClass("off on error").addClass("sync");
                zzcontacts.cc(e, function() {
                    a.find("div").removeClass("off sync error").addClass("on");
                    a.attr("title", "Last imported a moment ago.");
                    a.removeAttr("disabled")
                }, function(g, j) {
                    a.find("div").removeClass("off sync on").addClass("error");
                    a.attr("title", "There was an error: " + j + ".");
                    a.removeAttr("disabled")
                })
            })
        })
    }};
if ($.Oa.tb == "Mac")$("html").addClass("os-mac"); else $.Oa.tb == "Windows" && $("html").addClass("os-win");
(function(b) {
    b.Ka("ui.zz_dialog", {options:{Q:d,Vc:d,top:"auto",left:"auto",ya:d,height:"auto",width:"auto"},sa:function() {
        var c = this,a = this.element;
        if (a.parent().parent().size() <= 0) {
            a.css("display", "none");
            b("body").append(a)
        }
        a.wrap('<div class="zz_dialog"><div id="zz_dialog_inner"></div></div>');
        a.css("display", "block");
        a.css("border", 0);
        a.css("margin", 0);
        if (c.options.Vc) {
            a.before('<a href="javascript:void(0)" class="zz_dialog_closer"></a>');
            b(".zz_dialog_closer").click(function() {
                c.close()
            })
        }
        c.n =
                a.parent().parent();
        c.n.data("originalelement", c.element);
        c.Lc();
        c.wc = function() {
            c.Jb()
        };
        c.gc = function(e) {
            e.stopPropagation()
        };
        if (c.options.Q) {
            c.n.css("z-index", 99999);
            b("body").append('<div class="zz_dialog_scrim"></div>');
            c.zb = b("body").find(".zz_dialog_scrim")
        }
    },ke:function() {
        this.options.ya && this.open()
    },open:function() {
        if (this.va("beforeopen") !== k) {
            b("div.zz_dialog").not(this.n).each(function() {
                b(this).data("originalelement").u("close")
            });
            this.Jb();
            b(window).resize(this.wc);
            if (this.options.Q) {
                b(this.zb).show();
                b(window).keypress(this.gc)
            }
            this.n.fadeIn("fast");
            this.va("open")
        }
    },close:function() {
        if (this.va("beforeclose") !== k) {
            this.n.fadeOut("fast");
            this.options.Q && b(this.zb).hide();
            b(window).unbind("resize", this.wc);
            b(document).unbind("keypress", this.gc);
            this.va("close");
            this.F()
        }
    },toggle:function() {
        this.n.css("display") == "none" ? this.open() : this.close()
    },F:function() {
        b.La.prototype.F.apply(this, arguments);
        this.options.Q && this.zb.remove();
        this.n.empty().remove()
    },Lc:function() {
        var c = this.options;
        c.height ==
                "auto" ? this.n.css("height", b(this.element).outerHeight(d)) : this.n.css("height", c.height);
        c.width == "auto" ? this.n.css("width", b(this.element).outerWidth(d)) : this.n.css("width", c.width)
    },Jb:function() {
        this.options.top == "auto" ? this.n.css("top", b(window).height() / 2 - this.n.height() / 2) : this.n.css("top", this.options.top);
        this.options.left == "auto" ? this.n.css("left", b(window).width() / 2 - this.n.width() / 2) : this.n.css("left", this.options.left)
    }})
})(jQuery);
(function(b) {
    b.fn.Kd = function() {
        for (var c = this.position().top,a = this.prev(),e = []; a.length > 0 && a.position().top === c;) {
            e.push(a[0]);
            a = a.prev()
        }
        return b(e)
    };
    b.fn.Ld = function() {
        for (var c = this.position().top,a = this.next(),e = []; a.length > 0 && a.position().top === c;) {
            e.push(a[0]);
            a = a.next()
        }
        return b(e)
    };
    b.fn.Pb = function(c) {
        b.each(this, function(a, e) {
            var f = b(e);
            f.animate({left:parseInt(f.css("left")) + c,top:parseInt(f.css("top")) + 0}, 100, void 0)
        })
    }
})(jQuery);
var C = {},D = k;
function ba() {
    var b = {};
    $(".zzlike").each(function(c, a) {
        b[$(a).attr("data-zzid")] = $(a).attr("data-zztype")
    });
    if ($.td(b))D = d; else G(b)
}
function G(b) {
    $.td(b) || $.ajax({type:"POST",url:w.a + "/likes.json",data:{wanted_subjects:b},g:function(c) {
        if (D) {
            $.extend(C, c);
            for (key in c)H(key)
        } else {
            C = c;
            fa();
            D = d
        }
    },dataType:"json"})
}
function ga() {
    var b = $(this).attr("data-zzid"),c = $(this).attr("data-zztype"),a = w.a + "/likes/" + b,e = "like." + c + ".",f = "POST";
    if (C[b].user == d) {
        f = "DELETE";
        e += "unlike"
    } else e += "like";
    I(b);
    $.ajax({type:f,url:a,data:{mf:c},g:function(g) {
        $("body").append(g);
        ha(b)
    },error:function(g) {
        I(b);
        g.status == 401 && J("You must be logged in to like the " + c + "!")
    }});
    M(e)
}
function I(b) {
    if (D && b in C) {
        if (C[b].user == d) {
            C[b].user = k;
            C[b].count -= 1
        } else {
            C[b].user = d;
            C[b].count += 1
        }
        H(b)
    }
}
function fa() {
    $(".zzlike").each(function(b, c) {
        var a = $(c),e = a.attr("data-zzid");
        if (a.attr("data-zzstyle") == "menu")a.find("span.like-count").html("(" + C[e].count.toString() + ")"); else {
            button = $(' <div class="zzlike-button">Like</div>');
            icon = $("<span></span>");
            counter = $('<div class="zzlike-count">' + C[e].count + "</div>");
            C[e].user ? $(icon).addClass("zzlike-thumbup") : $(icon).addClass("zzlike-vader");
            $(button).prepend(icon);
            a.empty();
            a.append(button).append(counter)
        }
        a.click(ga)
    })
}
function H(b) {
    C[b] && $('.zzlike[data-zzid="' + b + '"]').each(function() {
        if ($(this).attr("data-zzstyle") == "menu")$(this).find("span.like-count").html("(" + C[b].count.toString() + ")"); else {
            C[b].user ? $(this).find("span.zzlike-vader").addClass("zzlike-thumbup").removeClass("zzlike-vader") : $(this).find("span.zzlike-thumbup").addClass("zzlike-vader").removeClass("zzlike-thumbup");
            $(this).find("div.zzlike-count").html(C[b].count)
        }
    })
}
function ha(b) {
    $("#facebook_box").click(function() {
        if ($(this).is(":checked") && !$("#facebook_box").attr("authorized")) {
            $(this).attr("checked", k);
            oauthmanager.Sa(w.a + "/facebook/sessions/new", function() {
                $("#facebook_box").attr("checked", d);
                $("#facebook_box").attr("authorized", "yes")
            })
        }
    });
    $("#twitter_box").click(function() {
        if ($(this).is(":checked") && !$("#twitter_box").attr("authorized")) {
            $(this).attr("checked", k);
            oauthmanager.Sa(w.a + "/twitter/sessions/new", function() {
                $("#twitter_box").attr("checked",
                        d);
                $("#twitter_box").attr("authorized", "yes")
            })
        }
    });
    $("#social-like-dialog").u({ya:k});
    $("#ld-cancel").click(function() {
        $("#social-like-dialog").u("close");
        $("#social-like-dialog").u().empty().remove()
    });
    $("#ld-ok").click(function() {
        $.ajax({type:"POST",url:w.a + "/likes/" + b + "/post",data:$("#social_like_form_" + b).serialize()});
        $("#social-like-dialog").u("close");
        $("#social-like-dialog").u().empty().remove()
    });
    $("#social-like-dialog").u("open")
}
var ia = {};
(function(b) {
    b.Ka("ui.zzlike_menu", {options:{anchor:k},sa:function() {
        var c = this,a = this.element;
        a.css("display", "none").addClass("like-menu");
        var e = b(a).find(".zzlike").attr("data-zzstyle", "menu");
        switch (e.length) {case 1:a.addClass("one-item");break;case 2:a.addClass("two-items");break;case 3:a.addClass("three-items")
        }
        b.each(e, function() {
            switch (b(this).attr("data-zztype")) {case "user":b(this).addClass("like-user").html('Person <span class="like-count"></span>');break;case "album":b(this).addClass("like-album").html('Album <span class="like-count"></span>');
                break;case "photo":b(this).addClass("like-photo").html('Photo <span class="like-count"></span>')
            }
        });
        a.parent().size() <= 0 && b("body").append(a);
        c.options.anchor && b(c.options.anchor).click(function() {
            c.open(this)
        })
    },open:function(c) {
        var a = this.element;
        if (a.is(":hidden"))if (this.va("beforeopen") !== k) {
            var e = b(c).offset();
            c = b(c).outerWidth() / 2 + e.left - a.width() / 2;
            e = b(document).height() - e.top;
            a.css({left:c,bottom:e}).slideDown("fast");
            b(a).hover(m(), function() {
                b(this).slideUp("fast")
            });
            setTimeout(function() {
                b(document).click(function() {
                    if (a.is(":visible")) {
                        b(document).unbind("click");
                        b(a).slideUp("fast")
                    }
                    return k
                })
            }, 0);
            b(window).one("resize", function() {
                b(a).css("display", "none")
            });
            this.va("open")
        }
    },F:function() {
        b.La.prototype.F.apply(this, arguments)
    }})
})(jQuery);
function B(b) {
    typeof console != "undefined" && console.log(b)
}
var N = "";
function ja(b, c) {
    b.load(w.a + "/albums/" + w.e + "/name_album", function() {
        N = $("#album_name").val();
        $("h2#album-header-title").text(N);
        $("#album_name").keypress(function() {
            setTimeout(function() {
                $("#album-header-title").text($("#album_name").val())
            }, 10)
        });
        setTimeout(function() {
            $("#album_name").select()
        }, 100);
        $("#album_name").keypress(function() {
            album_email_call_lock++;
            setTimeout(function() {
                album_email_call_lock--;
                album_email_call_lock == 0 && $.ajax({url:w.a + "/albums/" + w.e + "/preview_album_email?" + $.param({Nb:$("#album_name").val()}),
                    g:function(a) {
                        $("#album_email").val(a)
                    },error:function() {
                        $("#album_name").val(N);
                        $("h2#album-header-title").text(N)
                    }})
            }, 1E3)
        });
        $.ajax({dataType:"json",url:w.a + "/albums/" + w.e + "/photos_json?" + (new Date).getTime(),g:function(a) {
            var e = -1,f = $("#album_cover_photo").val();
            a = $.map(a, function(g, j) {
                var h = g.id;
                if (h == f)e = j;
                var l = g.$;
                l = u(l);
                return{id:h,src:l}
            });
            $("#album-cover-picker").qa({d:a,S:d,selectedIndex:e,Ua:function(g, j) {
                var h = "";
                if (g !== -1)h = j.id;
                $("#album_cover_photo").val(h)
            }})
        }});
        c()
    })
}
function ka(b) {
    $.ajax({type:"POST",url:w.a + "/albums/" + w.e,data:$(".edit_album").serialize(),g:b,error:function() {
        $("#album_name").val(N);
        $("h2#album-header-title").text(N);
        $("#album_name").keypress()
    }})
}
function la() {
    $.ajax({dataType:"json",url:w.a + "/albums/" + w.e + "/photos_json?" + (new Date).getTime(),g:function(b) {
        for (var c = 0; c < b.length; c++) {
            var a = b[c];
            a.J = u(a.Db);
            a.src = u(a.$)
        }
        b.push({id:i,type:"blank",caption:""});
        c = $('<div class="photogrid"></div>');
        $("#article").html(c);
        $("#article").css("overflow", "hidden");
        $("#article").css("top", "120px");
        c.C({d:b,v:d,k:230,p:230,Ca:function(e, f) {
            $.ajax({type:"DELETE",dataType:"json",url:w.a + "/photos/" + f.id + ".json",error:function(g) {
                B(g)
            },g:function() {
                z("/albums/" +
                        w.e + "/photos/" + f.id + "/cancel_upload")
            }});
            return d
        },N:d,Ba:function(e, f, g) {
            $.ajax({type:"PUT",dataType:"json",url:w.a + "/photos/" + f.id + ".json",data:{"photo[caption]":g},error:function(j) {
                B(j)
            }});
            return d
        },xa:d,lc:function(e, f, g) {
            var j = {};
            if (f)j.te = f;
            if (g)j.pe = g;
            $.ajax({type:"PUT",data:j,dataType:"json",url:w.a + "/photos/" + e + "/position",error:function(h) {
                B(h)
            }});
            return d
        },Fa:d}).data();
        $("#article").show()
    }})
}
function ma(b, c) {
    b.load(w.a + "/albums/" + w.e + "/privacy", function() {
        $("#privacy-public").click(function() {
            $.post(w.a + "/albums/" + w.e, "_method=put&album%5Bprivacy%5D=public", function() {
                $("img.select-button").attr("src", "/images/btn-round-selected-off.png");
                $("#privacy-public img.select-button").attr("src", "/images/btn-round-selected-on.png")
            })
        });
        $("#privacy-hidden").click(function() {
            $.post(w.a + "/albums/" + w.e, "_method=put&album%5Bprivacy%5D=hidden");
            $("img.select-button").attr("src", "/images/btn-round-selected-off.png");
            $("#privacy-hidden img.select-button").attr("src", "/images/btn-round-selected-on.png")
        });
        $("#privacy-password").click(function() {
            $.post(w.a + "/albums/" + w.e, "_method=put&album%5Bprivacy%5D=password");
            $("img.select-button").attr("src", "/images/btn-round-selected-off.png");
            $("#privacy-password img.select-button").attr("src", "/images/btn-round-selected-on.png")
        });
        c()
    })
}
function na(b, c) {
    var a,e;
    if (_.P(a))a = "album";
    if (_.P(e))e = w.e;
    var f = this;
    b.load(w.a + "/shares/new", function() {
        w.c.A();
        $(".social-share").click(function() {
            f.lf(b, a, e)
        });
        $(".email-share").click(function() {
            f.kf(b, a, e)
        });
        c()
    })
}
function O(b, c, a) {
    var e = this,f = $('<div id="share-dialog-content"></div>');
    $('<div id="share-dialog"></div>').html(f).u({height:580,width:895,Q:d,ya:d,open:function() {
        e.init(f, m(), b, c)
    },close:function() {
        _.P(a) || a()
    }})
}
var P = k;
function oa(b) {
    this.url = w.a + "/albums/" + w.e + "/contributors";
    Q(b)
}
function Q(b, c) {
    b.load("", function() {
        if (tmp_contact_list.length <= 0) {
            P = k;
            R(b)
        } else {
            P = d;
            $("#contributors-list").$d("", {Rc:k,ze:d,Ye:{data:tmp_contact_list,He:d},Yc:{ae:"token-input-list-facebook",Yd:"token-input-token-facebook",Zd:"token-input-delete-token-facebook",Pd:"token-input-selected-token-facebook",md:"token-input-highlighted-token-facebook",ed:"token-input-dropdown-facebook",fd:"token-input-dropdown-item-facebook",gd:"token-input-dropdown-item2-facebook",Nd:"token-input-selected-dropdown-item-facebook",
                sd:"token-input-input-token-facebook"}});
            $("#contributors-list").bind("tokenDeleted", function(a, e, f, g) {
                $.post("", {le:"delete",id:e}, function(j, h, l) {
                    w.c.Qa(l, 200);
                    if (g <= 0) {
                        P = k;
                        b.fadeOut("fast", function() {
                            R(b)
                        })
                    }
                })
            });
            w.c.A();
            $("#add-contributors-btn").click(function() {
                b.fadeOut("fast", function() {
                    R(b)
                })
            });
            b.fadeIn("fast", function() {
                typeof c != "undefined" && w.c.Qa(c, 200)
            })
        }
    })
}
function R(b) {
    b.load(w.a + "/albums/" + w.e + "/contributors/new", function() {
        $("#contact-list").$d(zzcontacts.find, {Rc:d,Yc:{ae:"token-input-list-facebook",Yd:"token-input-token-facebook",Zd:"token-input-delete-token-facebook",Pd:"token-input-selected-token-facebook",md:"token-input-highlighted-token-facebook",ed:"token-input-dropdown-facebook",fd:"token-input-dropdown-item-facebook",gd:"token-input-dropdown-item2-facebook",Nd:"token-input-selected-dropdown-item-facebook",sd:"token-input-input-token-facebook"}});
        zzcontacts.init(w.r);
        w.c.A();
        $("#new_contributors").L({rules:{contact_list:{required:d},contact_message:{required:d}},rb:{contact_list:"Empty",contact_message:""},Vd:function() {
            $.ajax({type:"POST",url:w.a + "/albums/" + w.e + "/contributors.json",data:$("#new_contributors").serialize(),g:function(c, a, e) {
                b.fadeOut("fast", "swing", function() {
                    Q(b, e)
                })
            }})
        }});
        P ? $("#cancel-new-contributors").click(function() {
            b.fadeOut("fast", function() {
                Q(b)
            })
        }) : $("#cancel-new-contributors").hide();
        $("#submit-new-contributors").click(function() {
            $("form#new_contributors").submit()
        });
        b.fadeIn("fast")
    })
}
var S = "undefined";
function pa(b, c) {
    b.load(w.a + "/users/" + w.r + "/edit", function() {
        w.I.na.Fd = window.location;
        $("div#drawer-content div#scroll-body").css({height:w.z - 140 + "px"});
        $(T.element).L(T);
        $("#user_username").keypress(function() {
            setTimeout(function() {
                $("#username-path").text($("#user_username").val())
            }, 10)
        });
        qa();
        ra();
        $("#profile-photo-button").click(sa);
        $("#ok-profile-button").click(function() {
            V(function() {
                w.c.Pa()
            })
        });
        $("#cancel-profile-button").click(w.c.Pa);
        c()
    })
}
function ta(b) {
    this.sf(b)
}
function ua(b) {
    $.ajax({dataType:"json",url:w.a + "/albums/" + w.e + "/photos_json?" + (new Date).getTime(),g:function(c) {
        var a = -1,e = $("#profile-photo-id").val();
        c = $.map(c, function(f, g) {
            var j = f.id;
            if (j == e)a = g;
            var h = f.$;
            h = u(h);
            return{id:j,src:h}
        });
        b(c, a)
    }})
}
function qa() {
    ua(function(b, c) {
        S = $("#profile-photo-picker").qa({d:b,S:d,selectedIndex:c,Ua:function(a, e) {
            var f = "";
            if (a !== -1)f = e.id;
            $("#profile-photo-id").val(f);
            $("div#profile-photo-picker div.thumbtray-wrapper div.thumbtray-selection").css("top", 0)
        }}).data().qa;
        S.Za(b);
        S.Ab(c)
    })
}
function va() {
    ua(function(b, c) {
        S.Za(b);
        S.Ab(c)
    })
}
function ra() {
    var b = $('<div class="photochooser-container"></div>');
    $('<div id="add-photos-dialog"></div>').html(b).u({height:$(document).height() - 200,width:895,Q:d,ya:k,open:function() {
        b.Ec({})
    },close:function() {
        $.ajax({url:w.a + "/albums/" + w.e + "/close_batch",complete:function(c, a) {
            B("Batch closed because Add photos dialog was closed. Call to close_batch returned with status= " + a)
        },g:function() {
            va()
        }})
    }});
    b.height($(document).height() - 192)
}
function sa() {
    $("#add-photos-dialog").u("open")
}
function V(b) {
    if ($(this.Cc.element).L()) {
        var c = $(this.Cc.element).serialize();
        $.ajax({type:"POST",url:w.a + "/users/" + w.r + ".json",data:c,g:function() {
            $("#user_old_password").val("");
            $("#user_password").val("");
            typeof b !== "undefined" && b()
        },error:function() {
            $("#user_old_password").val("");
            $("#user_password").val("")
        }})
    }
}
var T = {element:"#profile-form form",Xb:"#flashes-notice",rules:{"user[first_name]":{required:d,t:5},"user[last_name]":{required:d,t:5},"user[username]":{required:d,t:1,maxlength:25,wb:"(^[a-z0-9]+$|^[a-z0-9]+:.{8}$)",Y:"/service/users/validate_username"},"user[email]":{required:d,lb:d,Y:"/service/users/validate_email"},"user[old_password]":{t:5,required:{xe:function() {
    B("length is " + $("#user_password").val().length);
    return $("#user_password").val().length > 0
}}},"user[password]":{t:5}},rb:{"user[first_name]":{required:"Please enter your first name.",
    t:"Please enter at least 5 letters"},"user[last_name]":{required:"Please enter your last name.",t:"Please enter at least 5 letters"},"user[username]":{required:"A username is required.",wb:"Only lowercase alphanumeric characters allowed",Y:"username already taken"},"user[email]":{required:"We promise we won&rsquo;t spam you.",lb:"Is that a valid email?",Y:"Email already used"},"user[password]":"Six characters or more please."},Vd:function() {
    V(function() {
        w.c.Pa()
    })
}};
function wa(b, c) {
    b.load(w.a + "/users/" + w.r + "/identities", function() {
        w.I.na.Fd = window.location;
        $(".delete-id-button").click(xa);
        $(".authorize-id-button").click(ya);
        $("div#drawer-content div#scroll-body").css({height:w.z - 110 + "px"});
        $("#ok_id_button").click(w.c.Pa);
        c()
    })
}
function xa() {
    B("Deleting ID with URL =  " + $(this).attr("value"));
    var b = $(this).attr("service");
    $.post($(this).attr("value"), {_method:"delete"}, function() {
        B("identity_deleted event for service " + b);
        $("#" + b + "-status").fadeOut("slow");
        $("#" + b + "-delete").fadeOut("fast", function() {
            $("#" + b + "-authorize").fadeIn("fast")
        })
    })
}
function ya() {
    B("Authorizing ID with URL =  " + $(this).attr("value"));
    var b = $(this).attr("service");
    oauthmanager.Sa($(this).attr("value"), function() {
        B("identity_linked event for service " + b);
        $("#" + b + "-status").fadeIn("slow");
        $("#" + b + "-authorize").fadeOut("fast", function() {
            $("#" + b + "-delete").fadeIn("fast", function() {
                if ($("#flashes-notice")) {
                    var c = "Your can now use " + b + " features throughout ZangZing";
                    $("#flashes-notice").text(c).fadeIn("fast", function() {
                        setTimeout(function() {
                            $("#flashes-notice").fadeOut("fast",
                                    function() {
                                        $("#flashes-notice").text("    ")
                                    })
                        }, 3E3)
                    })
                }
            })
        })
    })
}
function za(b) {
    $(".zangzing-downloader #download-btn").click(function() {
        Aa()
    });
    W = d;
    X(function() {
        $.isFunction(b) && b()
    });
    M("agentdownload.requested")
}
function aa(b) {
    $("<div></div>", {id:"no-agent-dialog"}).load("/static/connect_messages/no_agent.html", function() {
        $(".zangzing-downloader #download-btn").click(function() {
            Aa()
        });
        $(this).u({Q:d,width:910,height:510,close:function() {
            $.isFunction(b) && b();
            W = k
        }});
        W = d;
        X(function() {
            $("#no-agent-dialog").u("close")
        })
    });
    M("agentdownload.requested")
}
function X(b) {
    r(function(c) {
        if (c) {
            $(".zangzing-downloader #download-btn").attr("disabled", "disabled");
            $(".zangzing-downloader .step.four .graphic").addClass("ready");
            $.isFunction(b) && setTimeout(b, 2E3);
            M("agentdownload.ready")
        } else W && setTimeout(function() {
            X(b)
        }, 1E3)
    })
}
function Aa() {
    M("agentdownload.get");
    if ($.Oa.tb == "Mac")document.location.href = "http://downloads.zangzing.com/agent/darwin/ZangZing-Setup.pkg"; else if ($.Oa.browser == "Chrome")window.open("http://downloads.zangzing.com/agent/win32/ZangZing-Setup.exe"); else document.location.href = "http://downloads.zangzing.com/agent/win32/ZangZing-Setup.exe"
}
var W;
function J(b) {
    if (w.o === w.ba) {
        if (typeof b != "undefined" && typeof b == "string") {
            var c = $("<p>" + b + "</p>");
            c.addClass("flash-notice");
            $("#signin-flashbox").append(c);
            c.show();
            $("#signin-form-cancel-button").click(function() {
                c.remove()
            })
        }
        $("#header #sign-in-button").addClass("selected");
        $("#sign-in").show();
        $("#sign-up").hide();
        $("#small-drawer").show().animate({height:"500px",top:"56px"}, 500, "linear", function() {
            $("#user_session_email").focus()
        });
        w.o = w.ra
    }
}
(function(b, c) {
    b.Ka("ui.zz_photo", {options:{v:k,Ca:jQuery.H,maxHeight:120,maxWidth:120,caption:i,N:k,Ba:jQuery.H,src:i,J:i,f:i,Wa:i,ic:0,Ta:jQuery.H,Se:jQuery.H,la:i,eb:0,ec:k,nb:k,oa:k,ja:jQuery.H,O:i,type:"photo"},sa:function() {
        var a = this;
        if (a.options.Wa.data().C)a.pc = a.options.Wa.data().C;
        var e = "";
        e += '<div class="photo-caption"></div>';
        e += '<div class="photo-border">';
        e += '   <img class="photo-image">';
        e += '   <div class="photo-delete-button"></div>';
        e += '   <div class="photo-uploading-icon"></div>';
        e += '   <div class="photo-error-icon"></div>';
        e += '   <img class="bottom-shadow" src="/images/photo/bottom-full.png">';
        if (a.options.O.indexOf("chooser") === 0 && a.options.type === "photo") {
            e += '   <div class="photo-add-button"></div>';
            e += '   <div class="magnify-button"></div>'
        }
        e += "</div>";
        b(e).appendTo(this.element);
        a.D = this.element.find(".photo-border");
        a.G = this.element.find(".photo-image");
        a.ea = this.element.find(".photo-caption");
        a.ib = this.element.find(".photo-delete-button");
        a.de = this.element.find(".photo-uploading-icon");
        a.hd = this.element.find(".photo-error-icon");
        a.Rb = this.element.find(".bottom-shadow");
        a.ea.text(a.options.caption);
        if (a.options.type === "blank") {
            a.D.hide();
            a.ea.hide()
        }
        if (a.options.O.indexOf("chooser") === 0) {
            this.element.find(".magnify-button").click(function() {
                a.options.Ta("magnify")
            });
            a.element.find(".photo-add-button").click(function() {
                a.options.Ta("main")
            });
            a.options.type !== "photo" && a.D.addClass("no-shadow")
        }
        a.G.click(function() {
            a.options.Ta("main")
        });
        a.Na = 30;
        if (a.options.eb) {
            var f = 1 * a.options.eb;
            e = Math.min(a.options.maxWidth / f, (a.options.maxHeight - a.Na) / 1);
            f *= e;
            e *= 1
        } else e = f = Math.min(a.options.maxWidth, a.options.maxHeight);
        a.G.css({width:f,height:e});
        a.Rb.css({width:f + 14 + "px"});
        a.width = parseInt(a.element.css("width"));
        a.height = parseInt(a.element.css("height"));
        f += 10;
        e += 10;
        a.D.css({position:"relative",top:(a.height - e - a.Na) / 2,left:(a.width - f) / 2,width:f,height:e});
        a.options.ec && !a.options.nb && a.de.show();
        a.options.nb && a.hd.show();
        a.options.v ? a.ib.click(function() {
            if (a.options.Ca()) {
                a.ea.hide();
                a.ib.hide();
                a.D.hide("scale", {}, 300, function() {
                    a.element.animate({width:0}, 500, function() {
                        a.element.remove();
                        a.pc && a.pc.Da()
                    })
                })
            }
        }) : a.ib.remove();
        a.options.N && a.ea.click(function() {
            a.Aa()
        });
        a.options.type !== "photo" ? a.Hb() : a.G.attr("src", "/images/photo_placeholder.png");
        if (a.options.f) {
            (new Image).src = a.options.f;
            a.element.mouseover(function() {
                a.G.attr("src", a.options.f)
            });
            a.element.mouseout(function() {
                a.G.attr("src", a.options.src)
            })
        }
        if (a.options.oa) {
            a.D.mouseenter(function() {
                a.Ia = b('<div class="photo-toolbar"><div class="buttons"><div class="share-button"></div><div class="like-button"></div><div class="info-button"></div></div></div>');
                a.D.append(a.Ia);
                a.D.css({"padding-bottom":"30px"});
                a.G.css({"border-bottom":"35px solid #fff"});
                a.Ia.find(".share-button").click(function() {
                    a.options.ja(a.options.la)
                });
                a.Ia.find(".like-button").click(function() {
                    alert("This feature is still under construction. This will allow you to like an individual photo.")
                });
                a.Ia.find(".info-button").click(function() {
                    alert("This feature is still under construction. This will show a menu with options for downloading original photo, etc.")
                })
            });
            a.D.mouseleave(function() {
                a.D.css({"padding-bottom":"0px"});
                a.G.css({"border-bottom":"5px solid #fff"});
                a.Ia.remove()
            })
        }
    },checked:k,Ne:function() {
        return this.checked
    },Ya:function(a) {
        this.checked = a;
        if (this.options.O.indexOf("chooser") === 0)a ? this.element.find(".photo-add-button").addClass("checked") : this.element.find(".photo-add-button").removeClass("checked")
    },ob:function(a) {
        this.nd || this.Jc(a) && this.Hb()
    },Hb:function() {
        var a = this,e = a.options.src;
        if (a.options.J)e = a.options.J;
        a.ga = new Image;
        a.ga.onload = function() {
            a.nd = d;
            a.Kc(1);
            a.G.attr("src", e);
            a.G.attr("src",
                    a.options.src)
        };
        a.ga.src = e
    },Kc:function() {
        var a = Math.min(this.options.maxWidth / this.ga.width, (this.options.maxHeight - this.Na) / this.ga.height),e = Math.floor(this.ga.width * a);
        a = Math.floor(this.ga.height * a);
        var f = e + 10,g = a + 10;
        this.D.css({top:(this.height - g - this.Na) / 2,left:(this.width - f) / 2,width:f,height:g});
        this.G.css({width:e,height:a});
        this.Rb.css({width:e + 14 + "px"})
    },Jc:function(a) {
        var e = this.options.Wa,f = this.options.ic;
        if (a)var g = a.offset,j = a.height,h = a.width; else {
            g = b(e).offset();
            j = b(e).height();
            h =
                    b(e).width()
        }
        a = b(this.element).offset();
        var l = this.options.maxWidth,p = this.options.maxHeight;
        if (e === c || e === window) {
            e = b(window).height() + b(window).scrollTop();
            j = b(window).width() + b(window).scrollLeft();
            h = b(window).scrollTop();
            g = b(window).scrollLeft()
        } else {
            e = g.top + j;
            j = g.left + h;
            h = g.top;
            g = g.left
        }
        p = h >= a.top + f + p;
        j = j <= a.left - f;
        e = e <= a.top - f;
        return!(g >= a.left + f + l) && !j && !p && !e
    },Aa:function() {
        var a = this;
        if (!a.dc) {
            a.dc = d;
            var e = b('<div class="edit-caption-border"><input type="text"><div class="caption-ok-button"></div></div>');
            a.ea.html(e);
            var f = e.find("input"),g = function() {
                var j = f.val();
                if (j !== a.options.caption) {
                    a.options.caption = j;
                    a.options.Ba(j)
                }
                a.ea.text(j);
                a.dc = k
            };
            f.val(a.options.caption);
            f.focus();
            f.select();
            f.blur(function() {
                g()
            });
            f.keydown(function(j) {
                if (j.which == 13) {
                    g();
                    return k
                } else if (j.which == 9) {
                    if (j.shiftKey) {
                        f.blur();
                        a.element.prev().length !== 0 ? a.element.prev().data().i.Aa() : a.element.parent().children().last().data().i.Aa()
                    } else {
                        f.blur();
                        a.element.next().length !== 0 ? a.element.next().data().i.Aa() : a.element.parent().children().first().data().i.Aa()
                    }
                    j.stopPropagation();
                    return k
                }
            });
            e.find(".caption-ok-button").click(function(j) {
                g();
                j.stopPropagation();
                return k
            })
        }
    },Je:function() {
        return this.options.la
    },dd:function() {
        this.element.addClass("dragging")
    },bd:function() {
        this.element.removeClass("dragging")
    },cd:function() {
        var a = this.element.clone();
        a.find(".photo-delete-button").hide();
        return a
    },F:function() {
        b.La.prototype.F.apply(this, arguments)
    }})
})(jQuery);
(function(b) {
    b.Ka("ui.zz_photochooser", {options:{},stack:[],W:i,sa:function() {
        var c = this,a = b('<div class="photochooser">   <div class="photochooser-header">       <a class="back-button"><span>Back</span></a>       <h3>Folder Name</h3>       <h4>Choose pictures from folders on your computer or other photo sites</h4>   </div>   <div class="photochooser-body"></div>   <div class="photochooser-footer">     <div class="added-pictures-tray"></div>   </div></div>');
        c.Sc = a.find(".back-button span");
        c.fb =
                a.find(".back-button");
        c.jd = a.find("h3");
        c.b = a.find(".photochooser-body");
        c.element.html(a);
        c.fb.click(function() {
            c.kd()
        });
        c.Sd();
        c.rd()
    },Sb:function(c) {
        var a = c.url,e = c.success,f = c.error;
        if (t(a)) {
            a = u(a);
            b.fc({url:a,g:function(g) {
                g.headers.status == 200 ? e(g.body) : f(g)
            },error:f})
        } else b.ajax({url:a,g:e,error:f})
    },kd:function() {
        this.stack.pop();
        this.ka(this.stack.pop())
    },Sd:function() {
        this.ka({name:"Home",children:this.Jd()})
    },ka:function(c) {
        var a = this;
        a.jd.text(c.name);
        if (a.stack.length > 0) {
            a.Sc.text(_.last(a.stack).name);
            a.fb.show()
        } else a.fb.hide();
        a.stack.push(c);
        a.b.html('<img class="progress-indicator" src="/images/loading.gif">');
        _.P(c.children) ? a.Sb({url:c.m,g:function(e) {
            a.Bb(c, e)
        },error:function(e) {
            _.P(c.l) ? alert("Sorry, there was a problem opening this folder. Please try again later.") : c.l(e)
        }}) : a.Bb(c, c.children)
    },Bb:function(c, a) {
        var e = this,f = k;
        a = b.map(a, function(h) {
            if (h.type === "folder") {
                if (typeof h.src === "undefined") {
                    h.src = "/images/folders/blank_off.jpg";
                    h.f = "/images/folders/blank_on.jpg"
                }
            } else {
                h.src =
                        u(h.$);
                h.id = h.Bc;
                f = d
            }
            h.caption = h.name;
            return h
        });
        if (f) {
            var g = {id:"add-all-photos",src:"",caption:"",type:"blank"};
            a.unshift(g)
        }
        var j = b('<div class="photogrid"></div>');
        e.b.html(j);
        e.W = j.C({d:a,Fa:k,k:190,p:190,O:"chooser-grid",ia:function(h, l, p, o) {
            if (l.type === "folder")e.ka(l); else if (o === "main")b(p).data().i.checked ? e.tc(l.id) : e.Kb(l.V, p); else if (o === "magnify") {
                f && a.shift();
                e.Ud(c, a, l.id)
            }
        }}).data().C;
        if (f) {
            g = b('<img class="add-all-button" src="/images/folders/add_all_photos.png">');
            g.click(function() {
                e.Nc(c.V,
                        g)
            });
            b(".photochooser .photochooser-body .photogrid").append(g)
        }
        e.Fb()
    },Ud:function(c, a, e) {
        var f = this;
        a = b.map(a, function(h) {
            h.J = u(h.$);
            h.src = u(h.Md);
            return h
        });
        var g = b('<a class="prev-button"></a><div class="singlepicture-wrapper"><div class="photogrid"></div></div><a class="next-button"></a>'),j = g.find(".photogrid");
        f.b.html(g);
        g.filter(".next-button").css({top:f.b.height() / 2 - 36});
        g.filter(".prev-button").css({top:f.b.height() / 2 - 36});
        f.W = j.C({d:a,Fa:k,bc:d,k:720,p:f.element.parent().height() - 130,
            B:d,w:e,O:"chooser-picture",ia:function(h, l, p, o) {
                if (l.type === "folder")f.ka(l); else if (o === "main")b(p).data().i.checked ? f.tc(l.id) : f.Kb(l.V, p); else o === "magnify" && f.Bb(c, a)
            }}).data().C;
        f.Fb();
        g.filter(".prev-button").click(function() {
            f.W.ma()
        });
        g.filter(".next-button").click(function() {
            f.W.X()
        })
    },R:function(c, a) {
        var e = this;
        oauthmanager.Sa(a, function() {
            e.ka(c)
        })
    },Jd:function() {
        function c(f) {
            if (typeof f.status === "undefined")a.b.hide().load("/static/connect_messages/no_agent.html", function() {
                za(function() {
                    a.ka(a.stack.pop());
                    a.b.css("top", "70px");
                    b(".photochooser-header").show()
                });
                b(".photochooser-header").css("display", "none");
                a.b.css("top", "0px");
                a.b.fadeIn("fast")
            }); else if (f.status === 401)a.b.hide().load("/static/connect_messages/wrong_agent_account.html", function() {
                a.b.fadeIn("fast")
            }); else f.status === 500 && a.b.hide().load("/static/connect_messages/general_agent_error.html", function() {
                a.b.fadeIn("fast")
            })
        }

        var a = this,e = [];
        if (navigator.appVersion.indexOf("Mac") != -1) {
            e.push({m:y("/filesystem/folders/fi9QaWN0dXJlcw=="),
                V:y("/filesystem/folders/fi9QaWN0dXJlcw==/add_to_album"),type:"folder",name:"My Pictures",l:c,src:"/images/folders/mypictures_off.jpg",f:"/images/folders/mypictures_on.jpg",state:"ready"});
            e.push({m:y("/iphoto/folders"),type:"folder",name:"iPhoto",l:c,src:"/images/folders/iphoto_off.jpg",f:"/images/folders/iphoto_on.jpg",state:"ready"});
            e.push({m:y("/picasa/folders"),type:"folder",name:"Picasa",l:c,src:"/images/folders/picasa_off.jpg",f:"/images/folders/picasa_on.jpg",state:"ready"});
            e.push({m:y("/filesystem/folders/fg=="),
                V:y("/filesystem/folders/fg==/add_to_album"),type:"folder",name:"My Home",l:c,src:"/images/folders/myhome_off.jpg",f:"/images/folders/myhome_on.jpg",state:"ready"});
            e.push({m:y("/filesystem/folders/L1ZvbHVtZXM="),type:"folder",name:"My Computer",l:c,src:"/images/folders/mycomputer_off.jpg",f:"/images/folders/mycomputer_on.jpg",state:"ready"})
        }
        if (navigator.appVersion.indexOf("Win") != -1) {
            e.push({m:y("/filesystem/folders/flxNeSBEb2N1bWVudHNcTXkgUGljdHVyZXM="),V:y("/filesystem/folders/flxNeSBEb2N1bWVudHNcTXkgUGljdHVyZXM=/add_to_album"),
                type:"folder",name:"My Pictures",l:c,src:"/images/folders/mypictures_off.jpg",f:"/images/folders/mypictures_on.jpg",state:"ready"});
            e.push({m:y("/picasa/folders"),type:"folder",name:"Picasa",l:c,src:"/images/folders/picasa_off.jpg",f:"/images/folders/picasa_on.jpg",state:"ready"});
            e.push({m:y("/filesystem/folders/fg=="),V:y("/filesystem/folders/fg==/add_to_album"),type:"folder",name:"My Home",l:c,src:"/images/folders/myhome_off.jpg",f:"/images/folders/myhome_on.jpg",state:"ready"});
            e.push({m:y("/filesystem/folders"),
                type:"folder",name:"My Computer",l:c,src:"/images/folders/mycomputer_off.jpg",f:"/images/folders/mycomputer_on.jpg",state:"ready"})
        }
        e.push({m:w.a + "/facebook/folders.json",type:"folder",name:"Facebook",src:"/images/folders/facebook_off.jpg",f:"/images/folders/facebook_on.jpg",l:function() {
            var f = this;
            a.b.hide().load("/static/connect_messages/connect_to_facebook.html", function() {
                a.b.find("#connect-button").click(function() {
                    a.R(f, w.a + "/facebook/sessions/new")
                });
                a.b.fadeIn("fast")
            })
        }});
        e.push({m:w.a + "/instagram/folders.json",
            type:"folder",name:"Instagram",src:"/images/folders/instagram_off.jpg",f:"/images/folders/instagram_on.jpg",l:function() {
                var f = this;
                a.b.hide().load("/static/connect_messages/connect_to_instagram.html", function() {
                    a.b.find("#connect-button").click(function() {
                        a.R(f, w.a + "/instagram/sessions/new")
                    });
                    a.b.fadeIn("fast")
                })
            }});
        e.push({m:w.a + "/shutterfly/folders.json",type:"folder",name:"Shutterfly",src:"/images/folders/shutterfly_off.jpg",f:"/images/folders/shutterfly_on.jpg",l:function() {
            var f = this;
            a.b.hide().load("/static/connect_messages/connect_to_shutterfly.html",
                    function() {
                        a.b.find("#connect-button").click(function() {
                            a.R(f, w.a + "/shutterfly/sessions/new")
                        });
                        a.b.fadeIn("fast")
                    })
        }});
        e.push({m:w.a + "/kodak/folders.json",type:"folder",name:"Kodak",src:"/images/folders/kodak_off.jpg",f:"/images/folders/kodak_on.jpg",l:function() {
            var f = this;
            a.b.hide().load("/static/connect_messages/connect_to_kodak.html", function() {
                a.b.find("#connect-button").click(function() {
                    a.R(f, w.a + "/kodak/sessions/new")
                });
                a.b.fadeIn("fast")
            })
        }});
        e.push({m:w.a + "/smugmug/folders.json",type:"folder",
            name:"SmugMug",src:"/images/folders/smugmug_off.jpg",f:"/images/folders/smugmug_on.jpg",l:function() {
                var f = this;
                a.b.hide().load("/static/connect_messages/connect_to_smugmug.html", function() {
                    a.b.find("#connect-button").click(function() {
                        a.R(f, w.a + "/smugmug/sessions/new")
                    });
                    a.b.fadeIn("fast")
                })
            }});
        e.push({m:w.a + "/flickr/folders.json",type:"folder",name:"Flickr",src:"/images/folders/flickr_off.jpg",f:"/images/folders/flickr_on.jpg",l:function() {
            var f = this;
            a.b.hide().load("/static/connect_messages/connect_to_flickr.html",
                    function() {
                        a.b.find("#connect-button").click(function() {
                            a.R(f, w.a + "/flickr/sessions/new")
                        });
                        a.b.fadeIn("fast")
                    })
        }});
        e.push({m:w.a + "/picasa/folders.json",type:"folder",name:"Picasa Web",src:"/images/folders/picasa_web_off.jpg",f:"/images/folders/picasa_web_on.jpg",l:function() {
            var f = this;
            a.b.hide().load("/static/connect_messages/connect_to_picasa_web.html", function() {
                a.b.find("#connect-button").click(function() {
                    a.R(f, w.a + "/picasa/sessions/new")
                });
                a.b.fadeIn("fast")
            })
        }});
        e.push({m:w.a + "/photobucket/folders",
            type:"folder",name:"Photobucket",src:"/images/folders/photobucket_off.jpg",f:"/images/folders/photobucket_on.jpg",V:w.a + "/photobucket/folders/import?album_path=/",l:function() {
                var f = this;
                a.b.hide().load("/static/connect_messages/connect_to_photobucket.html", function() {
                    a.b.find("#connect-button").click(function() {
                        a.R(f, w.a + "/photobucket/sessions/new")
                    });
                    a.b.fadeIn("fast")
                })
            }});
        e.push({m:w.a + "/zangzing/folders.json",type:"folder",name:"ZangZing",src:"/images/folders/zangzing_off.jpg",f:"/images/folders/zangzing_on.jpg"});
        return e
    },Fb:function() {
        var c = this;
        b.each(c.W.cells(), function(a, e) {
            b(e).data().i.Ya(k)
        });
        b.each(c.T, function(a, e) {
            var f = c.W.Xc(e.Bc);
            f && f.data().i.Ya(d)
        })
    },aa:i,T:[],Eb:i,rd:function() {
        var c = this;
        c.Eb = c.element.find(".added-pictures-tray");
        c.aa = c.Eb.qa({d:[],v:d,qe:k,mc:function(a, e) {
            c.sc(e.id)
        }}).data().qa;
        c.rc()
    },tc:function(c) {
        var a = _.ye(this.T, function(e) {
            return e.Bc == c
        });
        a && this.sc(a.id)
    },sc:function(c) {
        var a = this;
        b.ajax({type:"DELETE",dataType:"json",url:w.a + "/photos/" + c + ".json",g:function() {
            z("/albums/" +
                    w.e + "/photos/" + c + "/cancel_upload");
            a.rc()
        },error:function(e) {
            B(e)
        }})
    },rc:function() {
        var c = this;
        b.ajax({dataType:"json",url:w.a + "/albums/" + w.e + "/photos_json?" + (new Date).getTime(),g:function(a) {
            c.T = _.filter(a, function(e) {
                return w.r == e.fe
            });
            c.aa.Za(c.jc(c.T));
            c.Fb()
        }})
    },Kb:function(c, a) {
        var e = this;
        e.Qb(a, function() {
            e.Lb(c)
        });
        a.data().i.Ya(d)
    },Nc:function(c, a) {
        var e = this;
        e.Qb(a, function() {
            e.Lb(c)
        });
        b.each(e.W.cells(), function(f, g) {
            b(g).data().i.Ya(d)
        })
    },Qb:function(c, a) {
        var e;
        e = c.hasClass("add-all-button") ?
                c : c.find(".photo-image");
        var f = e.offset().top,g = e.offset().left,j = this.Eb.offset().top,h = this.ce();
        e.clone().css({position:"absolute",zIndex:2E3,left:g,top:f,border:"1px solid #ffffff"}).appendTo("body").addClass("animate-photo-to-tray").animate({width:"20px",height:"20px",top:j + "px",left:h + "px"}, 1E3, "easeInOutCubic", function() {
            a();
            b(this).remove()
        })
    },Lb:function(c) {
        var a = this;
        c += c.indexOf("?") == -1 ? "?" : "&";
        c += "album_id=" + w.e;
        a.aa.Rd();
        a.Sb({url:c,g:function(e) {
            a.T = a.T.concat(e);
            a.aa.Za(a.jc(a.T));
            a.aa.ac()
        },error:function(e) {
            a.aa.ac();
            alert("Sorry, there was a problem adding photos to your album. Please try again.");
            B(e)
        }})
    },Ke:function() {
        return self.T
    },jc:function(c) {
        b.isArray(c) || (c = [c]);
        return c = b.map(c, function(a) {
            var e = a.id;
            a = a.$;
            a = u(a);
            return{id:e,src:a}
        })
    },ce:function() {
        return this.aa.kc()
    }})
})(jQuery);
(function(b, c) {
    b.Ka("ui.zz_photogrid", {options:{d:[],k:200,p:200,v:k,Ca:jQuery.H,N:k,Ba:jQuery.H,xa:k,lc:jQuery.H,ia:jQuery.H,Fa:d,bc:k,B:k,w:i,nc:jQuery.H,O:"album-grid",oa:k,ja:jQuery.H},re:k,sa:function() {
        var a = this;
        a.options.B ? a.element.css({"overflow-y":"hidden","overflow-x":"scroll"}) : a.element.css({"overflow-y":"scroll","overflow-x":"hidden"});
        a.width = parseInt(a.element.css("width"));
        a.height = parseInt(a.element.css("height"));
        var e = b('<div class="photogrid-cell"><div class="photogrid-droppable"></div></div>');
        e.css({width:a.options.k,height:a.options.p});
        a.element.hide();
        var f = Math.floor(a.options.p * 0.8),g = Math.floor(a.options.k * 1),j = -1 * Math.floor(g / 2),h = Math.floor((a.options.p - f) / 2),l = [],p = 0;
        if (a.options.B)p = a.options.k * 3;
        b.each(a.options.d, function(n, q) {
            var x = e.clone();
            l.push(x);
            x.appendTo(a.element);
            x.i({Xe:q,la:q.id,J:q.J,src:q.src,f:q.f,maxWidth:Math.floor(a.options.k - 50),maxHeight:Math.floor(a.options.p - 50),v:a.options.v,caption:q.caption,eb:q.se,Ca:function() {
                return a.options.Ca(n, q)
            },N:a.options.N,
                Ba:function(E) {
                    return a.options.Ba(n, q, E)
                },Ta:function(E) {
                    a.options.ia(n, q, x, E)
                },Wa:a.element,ic:p,ec:!_.P(q.state) ? q.state !== "ready" : k,nb:q.state === "error",O:a.options.O,type:_.P(q.type) ? "photo" : q.type,oa:a.options.oa,ja:a.options.ja});
            if (a.options.xa) {
                var K = x.find(".photogrid-droppable");
                K.css({top:h,height:f,width:g,left:j});
                x.draggable({start:function() {
                    x.data().i.dd()
                },stop:function() {
                    x.data().i.bd()
                },Ae:m(),df:"invalid",ef:400,zIndex:2700,opacity:0.5,Le:function() {
                    return x.data().i.cd()
                },scroll:d,
                    ff:a.options.p / 8,gf:a.options.p / 3});
                var ca = Math.floor(a.options.k / 2);
                K.Ce({of:"pointer",We:function(E, U) {
                    if (U.draggable[0] != K.parent().prev()[0]) {
                        x.Kd().Pb(-1 * ca);
                        x.Ld().add(x).Pb(ca)
                    }
                },Ve:function() {
                    a.Da(100)
                },Be:function(E, U) {
                    var A = U.draggable,da = A.clone().appendTo(A.parent());
                    da.fadeOut(400, function() {
                        da.remove()
                    });
                    var L = K.parent();
                    A.insertBefore(L);
                    A.css({top:parseInt(L.css("top")),left:parseInt(L.css("left")) - a.options.k});
                    a.Da(800, "easeInOutCubic");
                    var Da = A.data().i.options.la,ea = i;
                    if (b(A).prev().length !==
                            0)ea = b(A).prev().data().i.options.la;
                    A = L.data().i.options.la;
                    a.options.lc(Da, ea, A)
                }})
            }
        });
        a.Da();
        a.element.show();
        this.element.children(".photogrid-cell").each(function(n, q) {
            b(q).data().i.ob()
        });
        var o = i;
        b(window).resize(function() {
            if (o) {
                clearTimeout(o);
                o = i
            }
            o = setTimeout(function() {
                a.width = parseInt(a.element.css("width"));
                a.height = parseInt(a.element.css("height"));
                a.Da();
                a.element.children(".photogrid-cell").each(function(n, q) {
                    _.P(b(q).data().i) || b(q).data().i.ob()
                })
            }, 100)
        });
        var s = i;
        a.element.scroll(function() {
            if (s) {
                clearTimeout(s);
                s = i
            }
            s = setTimeout(function() {
                var n = {offset:a.element.offset(),height:a.element.height(),width:a.element.width()};
                a.element.children(".photogrid-cell").each(function(q, x) {
                    b(x).data().i && b(x).data().i.ob(n)
                })
            }, 200)
        });
        if (a.options.bc)a.Ga = a.options.B ? b('<div class="photogrid-hide-native-scroller-horizontal"></div>').appendTo(a.element.parent()) : b('<div class="photogrid-hide-native-scroller-vertical"></div>').appendTo(a.element.parent());
        if (a.options.Fa) {
            var v = k;
            a.Ga = a.options.B ? b('<div class="photogrid-thumbscroller-horizontal"></div>').appendTo(a.element.parent()) :
                    b('<div class="photogrid-thumbscroller-vertical"></div>').appendTo(a.element.parent());
            var F = b.map(a.options.d, function(n) {
                return n.type == "blank" ? i : n
            });
            a.Xd = a.Ga.qa({d:F,$a:"previewSrc",S:k,K:20,zc:d,uc:d,Ua:function(n, q) {
                if (typeof q != "undefined")v || a.Xa(q.id, 500, d)
            }}).data().qa;
            a.element.scroll(function() {
                if (!a.Ma) {
                    v = d;
                    var n = a.options.B ? Math.floor(a.element.scrollLeft() / a.options.k) : Math.floor(a.element.scrollTop() / a.options.p * a.gb());
                    a.Xd.Ab(n);
                    v = k
                }
            })
        }
        if (a.options.B) {
            this.element.Qe(function(n) {
                (typeof n.wheelDelta !==
                        "undefined" ? n.wheelDelta : -1 * n.detail) < 0 ? a.X() : a.ma();
                return k
            });
            b(document.documentElement).keydown(function(n) {
                if (n.keyCode === 40)a.X(); else if (n.keyCode === 39)a.X(); else if (n.keyCode === 34)a.X(); else if (n.keyCode === 38)a.ma(); else if (n.keyCode === 37)a.ma(); else n.keyCode === 33 && a.ma()
            });
            b(this.element).keydown(function(n) {
                n.preventDefault()
            })
        }
        a.options.w && a.Xa(a.options.w, 0, k)
    },ld:function() {
        this.Ga.hide()
    },ha:k,X:function() {
        var a = this;
        if (!a.ha) {
            var e = a.Ra(a.w());
            e++;
            if (!(e > a.options.d.length - 1)) {
                e = a.options.d[e].id;
                a.ha = d;
                a.Xa(e, 500, d, function() {
                    a.ha = k
                })
            }
        }
    },ma:function() {
        var a = this;
        if (!a.ha) {
            var e = a.Ra(a.w());
            e--;
            if (!(e < 0)) {
                e = a.options.d[e].id;
                a.ha = d;
                a.Xa(e, 500, d, function() {
                    a.ha = k
                })
            }
        }
    },w:function() {
        return this.options.w ? this.options.w : this.options.d[0].id
    },Ra:function(a) {
        for (var e = 0; e < this.options.d.length; e++)if (this.options.d[e].id == a)return e;
        return-1
    },Xa:function(a, e, f, g) {
        function j() {
            h.options.w = a;
            h.options.nc(a);
            typeof g !== "undefined" && g()
        }

        var h = this;
        f = h.Ra(a);
        if (h.options.B) {
            f *= h.options.k;
            h.Ma = d;
            h.element.animate({scrollLeft:f},
                    e, "easeOutCubic", function() {
                        h.Ma = k;
                        j()
                    })
        } else {
            f = Math.floor(f / h.gb()) * h.options.p;
            h.Ma = d;
            h.element.animate({scrollTop:f}, e, "easeOutCubic", function() {
                h.Ma = k;
                j()
            })
        }
    },Da:function(a, e) {
        var f = this;
        if (a === c)a = 0;
        this.element.children(".photogrid-cell").each(function(g, j) {
            if (b(j).data().i) {
                var h = f.Dd(g);
                h = {top:h.top,left:h.left};
                a > 0 ? b(j).animate(h, a, e) : b(j).css(h)
            }
        })
    },Xc:function(a) {
        return this.Wc(this.Ra(a))
    },Wc:function(a) {
        a = this.element.children(":nth-child(" + (a + 1) + ")");
        return a.length === 0 ? i : a
    },cells:function() {
        return this.element.children(".photogrid-cell")
    },
        gb:function() {
            return this.options.B ? this.options.d.length : Math.floor(this.width / this.options.k)
        },Dd:function(a) {
            if (this.options.B)return{top:0,left:a * this.options.k}; else {
                var e = this.gb(),f = Math.floor(a / e),g = Math.floor((this.width - e * this.options.k) / 2);
                g -= 10;
                return{top:f * this.options.p,left:g + a % e * this.options.k}
            }
        },F:function() {
            this.Ga && this.Ga.remove();
            b.La.prototype.F.apply(this, arguments)
        }})
})(jQuery);
(function(b) {
    b.Ka("ui.zz_thumbtray", {options:{d:[],$a:"src",qc:120,xc:140,v:k,S:k,selectedIndex:-1,K:20,zc:k,uc:k,mc:m(),Ua:m(),Te:m()},fa:-1,selectedIndex:-1,Ja:i,orientation:i,U:"x",Fc:"y",Gb:"/images/photo_placeholder.png",sa:function() {
        function c() {
            j = k;
            setTimeout(function() {
                if (!j) {
                    f.h.fadeOut("fast");
                    f.options.S && f.q.animate({opacity:1}, 100)
                }
            }, 100)
        }

        function a() {
            j = d;
            f.h.fadeIn("fast")
        }

        function e() {
            var h = f.element.width(),l = f.element.height();
            f.orientation = h > l ? f.U : f.Fc;
            f.Dc.css({width:h,height:l});
            f.Z.css({width:h,height:l});
            f.xd.css({width:h,height:l});
            f.pa.css({width:h,height:l});
            if (f.orientation === f.U) {
                f.h.addClass("x");
                f.q.addClass("x");
                f.q.find("img").css({height:f.options.xc});
                f.h.find("img").css({height:f.options.qc});
                f.Ja = h
            } else {
                f.h.addClass("y");
                f.q.addClass("y");
                f.q.find("img").css({width:f.options.xc});
                f.h.find("img").css({width:f.options.qc});
                f.Ja = l
            }
        }

        var f = this,g = "";
        g += '<div class="thumbtray-wrapper">';
        g += '    <div class="thumbtray-thumbnails"></div>';
        g += '    <div class="thumbtray-selection">';
        g += '        <img src="/images/photo_placeholder.png">';
        g += "    </div>";
        g += '    <div class="thumbtray-preview">';
        g += '        <img src="/images/photo_placeholder.png">';
        g += '        <div class="thumbtray-delete-button"></div>';
        g += "    </div>";
        g += '    <img class="thumbtray-loading-indicator" src="/images/loading.gif"/>';
        g += '    <div class="thumbtray-mask"></div>';
        g += '    <div class="thumbtray-current-index-indicator"></div>';
        g += '    <div class="thumbtray-scrim"></div>';
        g += "</div>";
        this.element.html(g);
        this.Dc = this.element.find(".thumbtray-wrapper");
        this.Z = this.element.find(".thumbtray-scrim");
        this.xd = this.element.find(".thumbtray-mask");
        this.h = this.element.find(".thumbtray-preview");
        this.q = this.element.find(".thumbtray-selection");
        this.pa = this.element.find(".thumbtray-thumbnails");
        this.pb = this.element.find(".thumbtray-loading-indicator");
        this.Ea = this.element.find(".thumbtray-current-index-indicator");
        e();
        f.options.uc && b(window).resize(function() {
            e();
            f.ta()
        });
        this.ta();
        this.ua(this.options.selectedIndex);
        this.options.v && f.h.find(".thumbtray-delete-button").show().click(function() {
            f.h.find(".thumbtray-delete-button").hide();
            f.Hd(f.fa);
            f.h.hide("scale", {}, 300, function() {
                f.h.find(".thumbtray-delete-button").show()
            })
        });
        var j = k;
        f.Z.mousemove(function(h) {
            f.element.offset();
            if (i !== -1)f.orientation === f.U ? f.yc(h.pageX - f.element.offset().left) : f.yc(h.pageY - f.element.offset().top); else {
                c();
                f.Ib(-1)
            }
        });
        f.Z.mouseover(function() {
            a()
        });
        f.Z.mouseout(function() {
            c()
        });
        f.Z.mousedown(function() {
            f.ua(f.fa);
            if (f.options.S ===
                    d) {
                f.h.hide();
                f.q.css({opacity:1})
            }
        });
        f.h.mouseover(function() {
            a()
        });
        f.h.mouseout(function() {
            c()
        });
        f.h.click(function() {
            f.ua(f.fa);
            f.options.S === d && f.h.hide()
        })
    },yc:function(c) {
        this.Ib(this.Hc(c));
        this.h.show()
    },cb:function() {
        return this.Ja / this.options.K
    },db:function() {
        var c = this.options.d.length;
        return c * this.options.K < this.Ja ? this.options.K : this.Ja / c
    },je:function() {
        return this.options.K
    },Ib:function(c) {
        if (c !== this.fa) {
            this.fa = c;
            if (c !== -1) {
                this.h.find("img").attr("src", this.Gb);
                this.h.find("img").attr("src",
                        this.options.d[c][this.options.$a]);
                this.orientation === this.U ? this.h.css("left", this.ca(c) - this.h.width() / 2) : this.h.css("top", this.ca(c) - this.h.height() / 2);
                this.options.S && this.q.css({opacity:0.5})
            }
        }
    },he:function() {
        return this.fa
    },ua:function(c) {
        this.Od = c;
        if (c !== -1) {
            if (this.options.S === d) {
                this.q.find("img").attr("src", this.Gb);
                this.q.find("img").attr("src", this.options.d[c][this.options.$a]);
                this.q.show();
                this.q.css({opacity:1});
                this.orientation === this.U ? this.q.css("left", this.ca(c) - this.q.width() /
                        2) : this.q.css("top", this.ca(c) - this.q.height() / 2)
            }
            if (this.options.zc) {
                this.orientation === this.U ? this.Ea.css("left", this.ca(c) - this.Ea.width()) : this.Ea.css("top", this.ca(c) - this.Ea.height());
                this.Ea.show()
            }
        }
        this.options.Ua(c, this.options.d[c])
    },ie:function() {
        return this.Od
    },Hc:function(c) {
        c = Math.floor(c / this.db());
        if (!(c >= this.options.d.length))return c
    },ca:function(c) {
        return c * this.db() + this.db() / 2
    },ta:function() {
        var c = "",a = this.options.d.slice();
        if (a.length > this.cb())for (var e = a.length - this.cb(),
                                              f = (a.length - 2) / e; e > 0; e--)a.splice(Math.round(e * f), 1);
        for (e = 0; e < a.length; e++)c += '<img style="height:' + this.options.K + "px; width:" + this.options.K + 'px" src="' + a[e][this.options.$a] + '">';
        this.pa.html(c);
        this.orientation === this.U ? this.Z.css("width", a.length * this.options.K) : this.Z.css("height", a.length * this.options.K)
    },F:function() {
        this.element.html("");
        b.La.prototype.F.apply(this, arguments)
    },Hd:function(c) {
        this.options.mc(c, this.options.d[c]);
        this.options.d.splice(c, 1);
        this.ta()
    },Za:function(c) {
        this.options.d =
                c.slice();
        this.ua(-1);
        this.ta()
    },oe:function(c) {
        this.options.d = this.options.d.concat(c);
        this.ta()
    },kc:function() {
        return this.options.d.length === 0 ? this.pa.offset().left : this.options.d.length >= this.cb() ? this.pa.offset().left + this.pa.width() - 20 : this.pa.offset().left + this.options.d.length * 20
    },Ab:function(c) {
        this.ua(c)
    },Rd:function() {
        this.pb.css("left", this.kc() - this.Dc.offset().left);
        this.pb.show()
    },ac:function() {
        this.pb.hide()
    }})
})(jQuery);
function Ba(b, c, a) {
    z("/upload_status", function(e) {
        var f = e.uploads_in_progress,g = e.queued,j = [],h;
        for (h in f)j.push({e:f[h].album_id,Cd:f[h].photo_id,Uc:f[h].size - f[h].bytes_uploaded});
        for (h in g)j.push({e:g[h].album_id,Cd:g[h].photo_id,Uc:g[h].size});
        var l = k;
        g = f = 0;
        for (h in j) {
            if (!l && j[h].album_id === b)l = d;
            if (j[h].album_id === b)g += 1;
            if (l)f += j[h].bytes_remaining
        }
        j = 0;
        if (f > 0)j = f / e.ave_bytes_sec;
        a(j, 100 * (c - g) / c)
    })
}
var w = {view:"undefined",ba:0,ra:1,bb:2,o:0,xb:150,a:"/service",Va:function(b) {
    w.yb = $(window).height();
    w.z = w.yb - w.xb;
    $("#article").empty();
    $("div#drawer").show().animate({height:w.z + "px",top:"52px"}, b);
    $("div#drawer-content").animate({height:w.z - 14 + "px"}, b);
    w.c.A();
    w.o = w.ra
},vc:function(b, c) {
    w.yb = $(window).height();
    w.z = w.yb - w.xb;
    if (typeof c != "undefined" && c < w.z)w.z = c;
    $("div#drawer").animate({height:w.z + "px",top:"52px"}, b);
    $("div#drawer-content").animate({height:w.z - 0 + "px"}, b)
},Ub:function(b, c) {
    w.vc(b,
            c);
    $("#article").animate({opacity:1}, b * 1.1);
    w.o = w.bb
},hb:function(b) {
    $("#indicator").fadeOut("fast");
    $("div#drawer").animate({height:0,top:"10px"}, b);
    $("div#drawer-content").animate({height:0,top:"10px"}, b);
    $("#article").animate({opacity:1}, b * 1.1);
    w.o = w.ba
},De:function(b, c, a, e) {
    w.Va(b, c);
    $("#tab-content").load(a, function() {
        $("div#drawer-content div#scroll-body").css({height:w.z - 52 + "px"});
        e()
    })
}};
w.I = {$b:{first:"add",last:"share",Cb:d,sb:1,ub:0,style:"create",Ha:600,init:function() {
    w.wa = "group"
},oc:function() {
    $.ajax({url:w.a + "/albums/" + w.e + "/close_batch",complete:function(b, c) {
        B("Batch closed because drawer was closed. Call to close_batch returned with status= " + c);
        window.location = w.a + "/albums/" + w.e + "/photos"
    }})
},j:{add:{next:"name",title:"Add Photos",type:"full",url:w.a + "/albums/$$/add_photos",uf:"album",init:function(b, c) {
    var a = $('<div class="photochooser-container"></div>');
    b.html(a);
    a.Ec({});
    c()
},s:function(b) {
    b()
}},name:{id:"name",next:"edit",title:"Name",type:"full",init:function(b, c) {
    ja(b, c)
},s:function(b) {
    ka(b)
}},Ee:{next:"privacy",title:"Edit",type:"partial",init:function() {
    la()
},s:function(b) {
    b()
}},$e:{next:"contributors",title:"Privacy",type:"full",init:function(b, c) {
    ma(b, c)
},s:function(b) {
    b()
}},we:{next:"share",title:"Contributors",type:"full",init:function(b) {
    oa(b)
},s:function(b) {
    b()
}},jf:{next:0,title:"Share",type:"full",init:function(b, c) {
    na(b, c)
},s:function(b) {
    b()
}}}},na:{first:"profile",
    last:"linked_accts",Cb:k,sb:0,ub:0,style:"edit",Ha:600,init:m(),oc:m(),j:{profile:{next:"account",title:"Profile",type:"full",init:function(b, c) {
        pa(b, c)
    },s:function(b) {
        ta(b)
    }},me:{next:"notifications",title:"Account",type:"full",init:function(b, c) {
        b.empty();
        c()
    },s:function(b) {
        b()
    }},Re:{next:"linked-accts",title:"Notifications",type:"full",init:function(b, c) {
        b.empty();
        c()
    },s:function(b) {
        b()
    }},Oe:{next:0,title:"Linked Accounts",type:"full",init:function(b, c) {
        wa(b, c)
    },s:function(b) {
        b()
    }}}}};
w.init = {za:function() {
    $("#header #back-button").addClass("disabled");
    $("#header #view-buttons").children().addClass("disabled");
    $("#header #account-badge").addClass("disabled");
    $("#footer #play-button").addClass("disabled");
    $("#footer #next-button").addClass("disabled");
    $("#footer #prev-button").addClass("disabled");
    $("#footer #new-album-button").addClass("disabled");
    $("#footer #add-photos-button").addClass("disabled");
    $("#footer #share-button").addClass("disabled");
    $("#footer #edit-album-button").addClass("disabled");
    $("#footer #buy-button").addClass("disabled");
    $("#footer #like-button").addClass("disabled")
},Wb:function() {
    $("#header #back-button").removeClass("disabled");
    $("#header #view-buttons").children().removeClass("disabled");
    $("#header #account-badge").removeClass("disabled");
    $("#footer #play-button").removeClass("disabled");
    $("#footer #next-button").removeClass("disabled");
    $("#footer #prev-button").removeClass("disabled");
    $("#footer #new-album-button").removeClass("disabled");
    $("#footer #add-photos-button").removeClass("disabled");
    $("#footer #share-button").removeClass("disabled");
    $("#footer #edit-album-button").removeClass("disabled");
    $("#footer #buy-button").removeClass("disabled");
    $("#footer #like-button").removeClass("disabled")
},Wd:function() {
    $(document).ajaxSend(function(b, c, a) {
        a.data = a.data || "";
        a.data += (a.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(w.Ed)
    });
    $("#header #home-button").click(function() {
        document.location.href = w.a + "/";
        M("button.home.click")
    });
    if (w.vb == "photos")$("#header #view-buttons #grid-view-button").addClass("selected");
    else if (w.vb == "people")$("#header #view-buttons #people-view-button").addClass("selected"); else w.vb == "activities" && $("#header #view-buttons #activities-view-button").addClass("selected");
    $("#header #view-buttons #grid-view-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            M("button.gridview.click");
            $("#header #view-buttons").children().removeClass("selected");
            $("#header #view-buttons #grid-view-button").addClass("selected");
            $("#article").fadeOut(200);
            document.location.href =
                    w.M + "/photos"
        }
    });
    $("#header #view-buttons #picture-view-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            M("button.pictureview.click");
            $("#header #view-buttons").children().removeClass("selected");
            $("#header #view-buttons #picture-view-button").addClass("selected");
            $("#article").fadeOut(200);
            document.location.href = w.M + "/photos/#!"
        }
    });
    $("#header #view-buttons #people-view-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            M("button.peopleview.click");
            $("#header #view-buttons").children().removeClass("selected");
            $("#header #view-buttons #people-view-button").addClass("selected");
            $("#article").fadeOut(200);
            document.location.href = w.M + "/people"
        }
    });
    $("#header #view-buttons #activities-view-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            M("button.activitiesview.click");
            $("#header #view-buttons").children().removeClass("selected");
            $("#header #view-buttons #activities-view-button").addClass("selected");
            $("#article").fadeOut(200);
            document.location.href = w.M + "/activities"
        }
    });
    $("#header #help-button").click(function(b) {
        M("button.help.click");
        Zenbox.show(b)
    });
    $("#header #sign-in-button").click(function() {
        M("button.signin.click");
        J("")
    });
    $("#footer #play-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            M("button.play.click");
            $("<div></div>").css({position:"absolute",top:0,left:0,height:"100%",width:"100%","z-index":3E3,"background-color":"#000000",opacity:0}).appendTo("body").animate({opacity:1},
                    500, function() {
                        document.location.href = w.M + "/movie"
                    })
        }
    });
    $("#footer #new-album-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            M("button.createalbum.click");
            w.init.za();
            $("#footer #new-album-button").removeClass("disabled").addClass("selected");
            w.ab.qd();
            w.c.Zc()
        }
    });
    $("#footer #add-photos-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            w.init.za();
            $("#footer #add-photos-button").removeClass("disabled").addClass("selected");
            var b = $('<div class="photochooser-container"></div>');
            $('<div id="add-photos-dialog"></div>').html(b).u({height:$(document).height() - 200,width:895,Q:d,ya:d,open:function() {
                b.Ec({})
            },close:function() {
                $.ajax({url:w.a + "/albums/" + w.e + "/close_batch",complete:function(c, a) {
                    B("Batch closed because Add photos dialog was closed. Call to close_batch returned with status= " + a)
                },g:function() {
                    window.location.reload(k)
                }})
            }});
            b.height($(document).height() - 192)
        }
    });
    $("#footer #share-button").click(function() {
        if (!($(this).hasClass("disabled") ||
                $(this).hasClass("selected"))) {
            M("button.share.click");
            w.init.za();
            $("#footer #share-button").removeClass("disabled").addClass("selected");
            if (document.location.href.indexOf("/photos/#!") !== -1 || document.location.href.indexOf("/photos#!") !== -1) {
                var b = i,c = jQuery.param.Zb();
                if (c !== "")b = c.slice(1);
                O("photo", b, function() {
                    w.init.Wb();
                    $("#footer #share-button").removeClass("selected")
                })
            } else O("album", w.e, function() {
                w.init.Wb();
                $("#footer #share-button").removeClass("selected")
            })
        }
    });
    $("#footer #edit-album-button").click(function() {
        if (!($(this).hasClass("disabled") ||
                $(this).hasClass("selected"))) {
            w.init.za();
            $("#footer #edit-album-button").removeClass("disabled").addClass("selected");
            w.c.zd("add")
        }
    });
    $("#footer #buy-button").click(function() {
        alert("This feature is still under construction.")
    });
    $("#user_username").keyup(function() {
        var b = $("#user_username").val();
        $("#update-username").empty().text(b)
    });
    $("#step-sign-in-off").click(function() {
        $("#small-drawer").animate({height:"0px",top:"28px"}, function() {
            $("#sign-in").show();
            $("#sign-up").hide();
            $("#small-drawer").animate({height:"480px",
                top:"56px"}, 500, "linear", function() {
                $("#user_session_email").focus()
            })
        })
    });
    $("#step-join-off").click(function() {
        $("#small-drawer").animate({height:"0px",top:"28px"}, function() {
            $("#sign-up").show();
            $("#sign-in").hide();
            $("#small-drawer").animate({height:"480px",top:"56px"}, 500, "linear", function() {
                $("#user_name").focus()
            })
        })
    });
    $("#join_form_submit_button").click(function() {
        $("form#join-form").submit()
    });
    $("#join_form_cancel_button").click(function() {
        $("#small-drawer").animate({height:"0px",top:"28px"});
        w.o = w.ba;
        $("#header #sign-in-button").removeClass("selected")
    });
    $("#signin-form-cancel-button").click(function() {
        $("#small-drawer").animate({height:"0px",top:"28px"});
        w.o = w.ba;
        $("#header #sign-in-button").removeClass("selected")
    });
    $("#signin-form-submit-button").click(function() {
        $("form#new_user_session").submit()
    });
    $(w.L.Ac.element).L(w.L.Ac);
    $(w.L.join.element).L(w.L.join);
    w.init.Mc();
    w.init.vd();
    setTimeout(m(), 500)
},loaded:function() {
    $("#drawer-content").ajaxError(function(b, c) {
        w.c.ad(c, 50);
        w.c.Qa(c,
                50)
    });
    $("#drawer-content").ajaxSuccess(function(b, c) {
        w.c.Qa(c, 50)
    })
},Id:function() {
    w.o == w.ra && w.vc(50)
},mb:function(b, c) {
    $("#header #back-button span").text(b);
    $("#header #back-button").click(function() {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            $("#article").animate({left:$("#article").width()}, 500, "easeOutQuart");
            document.location.href = c
        }
    })
},Yb:function(b) {
    return $.map(b, function(c) {
        if (c.state !== "ready")if (_.P(w.r) || c.user_id != w.r)return i;
        return c
    })
},Oc:function() {
    var b =
            "grid";
    if (document.location.href.indexOf("/photos/#!") !== -1 || document.location.href.indexOf("/photos#!") !== -1)b = "picture";
    b === "grid" ? this.mb("All Albums", w.ee) : this.mb(w.Nb, w.M + "/photos");
    $.ajax({dataType:"json",url:w.a + "/albums/" + w.e + "/photos_json?" + w.Mb,g:function(c) {
        function a() {
            Ba(w.e, c.length, function(p, o) {
                o = Math.round(o);
                if (o < 100) {
                    var s = Math.round(p / 60),v = 0;
                    if (o > 0)v = Math.round(o / 6.25);
                    $("#progress-meter").css("background-image", "url(/images/upload-" + v + ".png)");
                    if (s === Infinity)$("#nav-status").text("Calculating...");
                    else {
                        v = "Minutes";
                        if (s === 1)v = "Minute";
                        $("#progress-meter-label").text(s + " " + v)
                    }
                    $("#progress-meter").show()
                } else $("#progress-meter").hide()
            })
        }

        M("album.view", {id:w.e});
        c = w.init.Yb(c);
        if (b === "grid") {
            var e = $('<div class="photogrid"></div>');
            $("#article").html(e);
            $("#article").css("overflow", "hidden");
            for (var f = 0; f < c.length; f++) {
                var g = c[f];
                g.J = u(g.Db);
                g.src = u(g.$)
            }
            var j = e.C({d:c,v:k,N:k,xa:k,k:230,p:230,ia:function(p, o) {
                j.ld();
                e.css({overflow:"hidden"});
                $("#article").css({overflow:"hidden"}).animate({left:-1 *
                        $("#article").width()}, 500, "easeOutQuart");
                document.location.href = w.M + "/photos/#!" + o.id
            },w:$.param.Zb(),oa:d,ja:function(p) {
                O("photo", p)
            }}).data().C
        } else {
            $("#view-buttons").hide();
            var h = function() {
                var p = $('<div class="photogrid"></div>');
                $("#article").html(p);
                $("#article").css("overflow", "hidden");
                for (var o = $(window).width() > 1200 && $(window).height() > 1E3,s = 0; s < c.length; s++) {
                    var v = c[s];
                    v.J = u(v.Db);
                    v.src = o ? u(v.Ie) : u(v.Md)
                }
                o = i;
                s = jQuery.param.Zb();
                if (s !== "")o = s.slice(1);
                var F = p.C({d:c,v:k,N:k,xa:k,k:p.width(),
                    p:p.height() - 20,ia:function() {
                        F.X();
                        M("button.next.click")
                    },B:d,w:o,nc:function(n) {
                        window.location.hash = "#!" + n;
                        M("photo.view", {id:n})
                    }}).data().C;
                $("#footer #next-button").unbind("click");
                $("#footer #next-button").show().click(function() {
                    F.X();
                    M("button.next.click")
                });
                $("#footer #prev-button").unbind("click");
                $("#footer #prev-button").show().click(function() {
                    F.ma();
                    M("button.previous.click")
                })
            };
            h();
            var l = i;
            $(window).resize(function() {
                if (l) {
                    clearTimeout(l);
                    l = i
                }
                l = setTimeout(function() {
                    h()
                }, 100)
            })
        }
        $("#progress-meter").hide();
        a();
        setInterval(a, 1E4);
        if (typeof ia != "undefined") {
            f = {};
            for (key in c) {
                id = c[key].id;
                f[id] = "photo"
            }
            G(f)
        }
    }})
},Ze:m(),Pc:function() {
    w.init.Ob("people")
},Qc:function() {
    w.init.Ob("timeline")
},Ob:function(b) {
    this.mb("All Albums", w.ee);
    $.ajax({dataType:"json",url:w.a + "/albums/" + w.e + "/photos_json?" + w.Mb,g:function(c) {
        c = w.init.Yb(c);
        for (var a = 0; a < c.length; a++) {
            var e = c[a];
            e.J = u(e.Db);
            e.src = u(e.$)
        }
        $(".timeline-grid").each(function(f, g) {
            $(g).empty();
            var j = i;
            if (b === "timeline") {
                var h = parseInt($(g).attr("data-upload-batch-id"));
                j = $(c).filter(function(s) {
                    return c[s].tf === h
                });
                var l = $('.viewlist .more-less-btn[data-upload-batch-id="' + h.toString() + '"]')
            } else {
                var p = parseInt($(g).attr("data-user-id"));
                j = $(c).filter(function(s) {
                    return c[s].fe === p
                });
                l = $('.viewlist .more-less-btn[data-user-id="' + p.toString() + '"]')
            }
            $(g).C({d:j,v:k,N:k,xa:k,k:230,p:230,ia:function(s, v) {
                $("#article").css({overflow:"hidden"}).animate({left:-1 * $("#article").width()}, 500, "easeOutQuart");
                document.location.href = w.M + "/photos/#!" + v.id
            },Fa:k,oa:d,ja:function(s) {
                O("photo",
                        s)
            }}).data();
            $(g).css({overflow:"hidden"});
            var o = k;
            l.click(function() {
                if (o) {
                    $(g).animate({height:230}, 500, "swing", function() {
                        l.find("span").html("Show more photos");
                        l.removeClass("open")
                    });
                    o = k
                } else {
                    $(g).animate({height:$(g).children().last().position().top + 180}, 500, "swing", function() {
                        $(g).trigger("scroll");
                        l.find("span").html("Show less photos");
                        l.addClass("open")
                    });
                    o = d
                }
            })
        })
    }})
},Mc:function() {
    w.ab.od();
    $("#account-badge").click(function() {
        $(this).hasClass("disabled") || $(this).hasClass("selected") ||
        w.ab.Td()
    })
},vd:function() {
    var b = $(w.ab.Tc()).ge();
    ba();
    $("#footer #like-button").click(function(c) {
        if (!($(this).hasClass("disabled") || $(this).hasClass("selected"))) {
            M("button.like.click");
            $(b).ge("open", this);
            c.stopPropagation()
        }
    })
}};
window.zz = w;
window.zz.current_user_id = w.r;
window.zz.current_user_name = w.$c;
window.zz.displayed_user_id = w.jb;
window.zz.album_id = w.e;
window.zz.album_type = w.wa;
window.zz.album_lastmod = w.Mb;
window.zz.album_type = w.wa;
window.zz.album_base_url = w.M;
window.zz.album_name = w.Nb;
window.zz.rails_controller_name = w.vb;
window.zz.rails_action_name = w.af;
window.zz.rails_authenticity_token = w.Ed;
window.zz.init = w.init;
window.zz.init.template = w.init.Wd;
window.zz.init.album = w.init.Oc;
window.zz.init.album_timeline_view = w.init.Qc;
window.zz.init.album_people_view = w.init.Pc;
window.zz.init.loaded = w.init.loaded;
window.zz.init.resized = w.init.Id;
w.ab = {qd:function() {
    $("#user-info").css("display", "none");
    $("#album-info h2").text("New Album");
    $("#album-info h3").text("by " + w.$c);
    $("#header .album-cover").attr("src", "/images/album-no-cover.png");
    $("#header .album-cover").css({width:"60px"});
    $("#album-info").css("display", "inline-block");
    w.c.Qd("create");
    $("div#cancel-drawer-btn").unbind("click").click(function() {
        $("#drawer .body").fadeOut("fast", function() {
            window.location.reload()
        });
        w.hb(400)
    })
},od:function() {
    $("ul.dropdown").hover(m(), function() {
        $(this).slideUp("fast")
    });
    $("ul.dropdown li a").click(function() {
        $(this).parent().parent().slideUp("fast")
    });
    $("#acct-settings-btn").click(function() {
        w.init.za();
        $("#header #account-badge").removeClass("disabled").addClass("selected");
        w.c.Ad("profile")
    });
    $("#acct-signout-btn").click(function() {
        window.location = w.a + "/signout"
    })
},Td:function() {
    $("#acct-dropdown").is(":visible") ? $("#acct-dropdown").slideUp("fast") : $("#acct-dropdown").slideDown("fast")
},Tc:function() {
    var b = "",c = "",a = "",e = "";
    if (typeof w.e != "undefined")a = $('<li class="zzlike" data-zzid="' +
            w.e + '" data-zztype="album"></li>');
    if (typeof w.jb != "undefined" && w.jb != w.r)c = $('<li class="zzlike" data-zzid="' + w.jb + '" data-zztype="user"></li>');
    if (location.hash && location.hash.length > 2) {
        e = $('<li id="like-menu-photo" class="zzlike" data-zzid="' + location.hash.substr(2) + '" data-zztype="photo"></li>');
        $(window).bind("hashchange", function() {
            var f = location.hash.substr(2);
            $("#like-menu-photo").attr("data-zzid", f);
            if (typeof f != "undefined" && typeof C[f] == "undefined") {
                var g = {};
                g[f] = "photo";
                G(g)
            } else H(f)
        })
    }
    b =
            $('<ul id="like-menu"></ul>');
    b.append(a);
    b.append(c);
    b.append(e);
    return b
}};
jQuery.Cc.ne("regex", function(b, c, a) {
    a = RegExp(a);
    return this.Ue(c) || a.test(b)
}, "Please check your input.");
w.L = {Ac:{element:"#new_user_session",Xb:"div#sign-in p.error-notice",rules:{"user_session[email]":{required:d,t:1},"user_session[password]":{required:d,t:5}},rb:{"user_session[email]":"Please enter your username or email address.","user_session[password]":"Please enter your password."},Fe:function() {
    $("div#sign-in p.error-notice").text("Please check the highlighted field(s) below...")
}},join:{element:"#join-form",Xb:"div#sign-up p.error-notice",rules:{"user[name]":{required:d,t:5},"user[username]":{required:d,
    t:1,maxlength:25,wb:"(^[a-z0-9]+$|^[a-z0-9]+:.{8}$)",Y:w.a + "/users/validate_username"},"user[email]":{required:d,lb:d,Y:w.a + "/users/validate_email"},"user[password]":{required:d,t:5}},rb:{"user[name]":{required:"Please enter your name.",t:"Please enter at least 5 letters"},"user[username]":{required:"A username is required.",wb:"Only lowercase alphanumeric characters allowed",Y:"username not available"},"user[email]":{required:"We promise we won&rsquo;t spam you.",lb:"Is that a valid email?",Y:"Email already used"},
    "user[password]":"Six characters or more please."}}};
w.c = {qb:function(b, c) {
    b.init();
    w.o == w.ba && w.Va(b.Ha, b.ub);
    w.c.da(b, c);
    var a = $("#tab-content");
    b.j[c].init(a, function() {
        w.c.A()
    });
    $("body").addClass("drawer")
},Tb:function(b, c) {
    B(c.j[b].type + "    " + w.o);
    var a = $("#tab-content");
    if (c.j[b].type == "partial" && w.o == w.ra) {
        $("#tab-content").fadeOut("fast");
        w.Ub(c.Ha, 40);
        w.c.da(c, b);
        c.j[b].init(a, function() {
            w.c.A()
        })
    } else if (c.j[b].type == "partial" && w.o == w.bb) {
        w.c.da(c, b);
        c.j[b].init(a, function() {
            w.c.A()
        })
    } else if (c.j[b].type == "full" && w.o == w.bb) {
        w.c.da(c, b);
        $("#tab-content").empty().show();
        c.j[b].init(a, function() {
            w.c.A();
            w.Va(c.Ha)
        })
    } else if (c.j[b].type == "full" && w.o == w.ra) {
        w.c.da(c, b);
        $("#tab-content").fadeOut(100, function() {
            $("#tab-content").empty();
            $("#tab-content").show();
            c.j[b].init(a, function() {
                w.c.A()
            })
        })
    } else if (c.j[b].type == "partial" && w.o == w.ba) {
        w.Va(80, c.ub);
        w.Ub(c.Ha);
        w.c.da(c, b);
        c.j[b].init(a, function() {
            w.c.A()
        })
    } else console.warn("This should never happen. Context: zz.wizard.change_step, Type: " + c.j[b].type + ", Drawer State: " + w.o)
},da:function(b, c, a) {
    var e = 1,f = "";
    $.each(b.j, function(g, j) {
        if (g == c && b.sb == 1) {
            value = e;
            f += '<li id="wizard-' + g + '" class="tab on">';
            f += '<img src="/images/wiz-num-' + e + '-on.png" class="num"> ' + j.title + "</li>"
        } else if (g == c) {
            value = e;
            f += '<li id="wizard-' + g + '" class="tab on">' + j.title + "</li>"
        } else if (b.sb == 1) {
            f += '<li id="wizard-' + g + '" class="tab">';
            f += '<img src="/images/wiz-num-' + e + '.png" class="num"> ' + j.title + "</li>"
        } else f += '<li id="wizard-' + g + '" class="tab">' + j.title + "</li>";
        e++
    });
    e--;
    if (b.Cb === d) {
        if (b.j[c].next == 0 || b.style ==
                "edit") {
            f += '<li class="next-done">';
            f += '<a id="next-step" class="green-button"><span>Done</span></a>'
        } else {
            f += '<li class="next-done">';
            f += '<a id="next-step" class="next-button"><span>Next</span></a>'
        }
        f += "</li>"
    }
    a && $("#drawer-tabs").hide();
    b.style == "edit" ? $("#drawer-tabs").html($("#clone-indicator").clone().attr("id", "indicator-" + e).addClass("edit-" + value + "-" + e).html(f)) : $("#drawer-tabs").html($("#clone-indicator").clone().attr("id", "indicator-" + e).addClass("step-" + value + "-" + e).html(f));
    a && $("#drawer-tabs").fadeIn("fast");
    w.c.A();
    $.each(b.j, function(g) {
        $("li#wizard-" + g).click(function(j) {
            j.preventDefault();
            e = $(this).attr("id").split("wizard-")[1];
            b.j[c].s(function() {
                w.c.Tb(e, b)
            })
        })
    });
    if (b.Cb === d)b.last == c || b.style == "edit" ? $("#next-step").click(function() {
        b.j[c].s(function() {
            $("#drawer .body").fadeOut("fast");
            w.hb(400);
            b.oc()
        })
    }) : $("#next-step").click(function(g) {
        g.preventDefault();
        b.j[c].s(function() {
            e = b.j[c].next;
            w.c.Tb(e, b)
        })
    })
},A:function() {
    $("div#drawer-content div#scroll-body").css({height:w.z - 140 + "px"})
},Qd:function(b) {
    if (b ==
            "edit") {
        $("div#drawer").css("background-image", "url(/images/bg-drawer-bottom-cap.png)");
        $("div#cancel-drawer-btn").hide()
    } else {
        $("div#drawer").css("background-image", "url(/images/bg-drawer-bottom-cap-with-cancel.png)");
        $("div#cancel-drawer-btn").show()
    }
    w.xb = 160
},Zc:function() {
    $.post(w.a + "/users/" + w.r + "/albums", {wa:"GroupAlbum"}, function(b) {
        w.e = b;
        w.c.qb(w.I.$b, "add")
    })
},zd:function(b) {
    switch (w.wa) {case "profile":case "group":if (typeof w.I.kb == "undefined") {
        w.I.kb = w.I.$b;
        w.I.kb.style = "edit"
    }w.c.qb(w.I.kb,
            b);break;default:B("zz.wizard.open_edit_album_wizard: Albums of type: " + w.wa + " are not supported yet.")
    }
},Ad:function(b) {
    w.c.qb(w.I.na, b)
},Pa:function() {
    $("#drawer .body").fadeOut("fast");
    w.hb(400);
    setTimeout(function() {
        window.location.reload(k)
    }, 1)
},Qa:function(b, c) {
    var a = b.getResponseHeader("X-Flash");
    if (a && a.length > 0 && $("#flashes-notice")) {
        a = $.Bd(a);
        a.yd && $("#flashes-notice").text(a.yd).fadeIn("fast", function() {
            setTimeout(function() {
                $("#flashes-notice").fadeOut("fast", function() {
                    $("#flashes-notice").text("    ")
                })
            },
                    c + 3E3)
        });
        a.error && $("#error-notice").text(a.error).fadeIn("fast", function() {
            setTimeout(function() {
                $("#error-notice").fadeOut("fast", function() {
                    $("#error-notice").text("    ")
                })
            }, c + 3E3)
        })
    }
},ad:function(b, c) {
    var a = b.getResponseHeader("X-Errors");
    if (a) {
        a = $.Bd(a);
        var e = "",f;
        for (f in a)if (typeof f !== "undefined") {
            e = a[f];
            break
        }
        $("#error-notice").text(e).fadeIn("fast", function() {
            c > 0 && setTimeout(function() {
                $("#error-notice").fadeOut("fast", function() {
                    $("#error-notice").text("    ")
                })
            }, c + 3E3)
        })
    }
}};
var Y = Y || [];
Y.push(["_setAccount",zza_config_GOOGLE_ANALYTICS_TOKEN]);
Y.push(["_trackPageview"]);
var Z = document.createElement("script");
Z.type = "text/javascript";
Z.async = d;
Z.src = ("https:" == document.location.protocol ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js";
var Ca = document.getElementsByTagName("script")[0];
Ca.parentNode.insertBefore(Z, Ca);
document.write(unescape("%3Cscript src='" + ("https:" == document.location.protocol ? "https://" : "http://") + "api.mixpanel.com/site_media/js/api/mixpanel.js' type='text/javascript'%3E%3C/script%3E"));
try {
    var Ea = new MixpanelLib(zza_config_MIXPANEL_TOKEN)
} catch(Fa) {
    null_fn = m();
    Ea = {pf:null_fn,qf:null_fn,Gd:null_fn,cf:null_fn,bf:null_fn}
}
Ea.Gd({referrer:document.referrer});
_zza = new ZZA(zza_config_ZZA_ID, zuserid, d);
_zza.init();
$(window).bind("beforeunload", function() {
    _zza.close()
});
function M(b, c) {
    if (typeof c == "undefined") {
        _zza.be(b, i);
        Y.push(["_trackPageview","/event/" + b]);
        Y.push(["_trackEvent","potd",b]);
        typeof console != "undefined" && console.log("ZZA event: " + b)
    } else {
        _zza.be(b, c);
        var a = "?",e;
        for (e in c)a += e + "=" + c[e] + "&";
        a = a.substring(0, a.length - 1);
        Y.push(["_trackPageview","/event/" + b + a]);
        Y.push(["_trackEvent","potd",b]);
        if (typeof console != "undefined") {
            console.log("ZZA event: " + b);
            console.log("ZZA properties: " + c)
        }
    }
}
M("page.visit", {rf:navigator.userAgent});
window.onerror = function(b, c, a) {
    try {
        c.indexOf("http://localhost:30777") == -1 && M("js.error", {message:b,url:c,wd:a});
        typeof console != "undefined" && console.log({message:b,url:c,wd:a})
    } catch(e) {
    }
    return k
};
