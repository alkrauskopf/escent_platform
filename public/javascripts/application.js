// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// jQuery.fn.addUIStateClass = function() {
//
//};

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var yes_html = '<input class="radio" checked="checked" value="Yes" name="status" type="radio">Yes <input class="radio" value="No" name="status" type="radio">No';
var no_html = '<input class="radio" value="Yes" name="status" type="radio">Yes <input class="radio" checked="checked" value="No" name="status" type="radio">No';

function headerSortDown(sort_url) {
    jQ.get(sort_url, {"sort":"headerSortDown"}, function(data) {
        jQ("#associations_warp").html(data);
    })
}

function headerSortUp(sort_url) {
    jQ.get(sort_url, {"sort":"headerSortUp"}, function(data) {
        jQ("#associations_warp").html(data);
    })
}

var addButtonActionForOurPartners = function($warp, post_url, url){
    jQ("button", $warp).each(function(){
        jQ(this).click(function(){
            removeRelationship($warp,jQ(this).parent("td").parent("tr").attr("id"),post_url,url);
            return false;
        })
    })

    jQ("input", $warp).each(function(){
        jQ(this).click(function(){
            jQ.post(url, {'relationship_id': jQ(this).attr("value"), 'include': jQ(this).attr("checked")})
        })
    })
}

function removeRelationship($warp, relationship_id, post_url, url){
    jQ.post(post_url, {
        'id': relationship_id
    }, function(data){
        $warp.html(data);
        addButtonActionForOurPartners($warp, post_url, url);
    })
}

(function($) {
    $.fn.addUserToPanel = function() {
        $(this).click(function() {
            $add_user_warp = jQ("#panel");
            var url = $add_user_warp.find("form").attr("action");
            var user_id = $add_user_warp.find("select").val();
            $.post(url, {"user_id":user_id}, function(data) {
                $add_user_warp.html(data);
            })
            return false;
        })
    }

    $.fn.removeUserFromPanel = function() {
        return this.each(function() {
            $(this).click(function() {
                $add_user_warp = jQ("#panel");
                var url = $(this).attr("href");
                $.post(url, function(data) {
                    $add_user_warp.html(data);
                })
                return false;
            })
        })
    }
// javascript for Admin/Our Causes/Topic Edit/Manage Content
// Show flash notice, if set a content as featured.
    $.fn.setFeatured = function(url, topic_id) {
        $(this).click(function(event) {
            $.post(url,{content_id: event.target.value, id: topic_id},
                function(data){
                    $("#update_notice").css("display","block");
                    $("#update_notice").html(data);
                }
            )
        })
    }

// Open and Close resource_levels
    $.fn.toggleResourceLevels = function() {
        return this.each(function() {
            $(this).click(function(event) {
                if (event.target == this) {
                    $this = $(this);
                    var url = $this.find("a").attr("href");
                    var className = $this.attr("class");
                    if (className == 'resource_levels_open') {
                        $this
                            .removeClass()
                            .addClass("resource_levels_close")
                            .find("span")
                            .html("");
                        // })
                    } else if (className == 'resource_levels_close') {
                        jQ.get(url,function(data) {
                            $this
                                .removeClass()
                                .addClass("resource_levels_open")
                                .find("span")
                                .html(data);
                        })
                    }
                    return false;
                }
            })
        })
    }

// Open and Close resource_levels
    $.fn.toggleRresourceLevels = function() {
        return this.each(function() {
            $(this).click(function(event) {
                if (event.target == this) {
                    $this = $(this);
                    var url = $this.find("a").attr("href");
                    var className = $this.attr("class");
                    if (className == 'rresource_levels_open') {
                        $this
                            .removeClass()
                            .addClass("rresource_levels_close")
                            .find("span")
                            .html("");
                        // })
                    } else if (className == 'rresource_levels_close') {
                        jQ.get(url,function(data) {
                            $this
                                .removeClass()
                                .addClass("rresource_levels_open")
                                .find("span")
                                .html(data);
                        })
                    }
                    return false;
                }
            })
        })
    }



// Open and Close ifa_levels
    $.fn.toggleIfaLevels = function() {
        return this.each(function() {
            $(this).click(function(event) {
                if (event.target == this) {
                    $this = $(this);
                    var url = $this.find("a").attr("href");
                    var className = $this.attr("class");
                    if (className == 'ifa_levels_open') {
                        $this
                            .removeClass()
                            .addClass("ifa_levels_close")
                            .find("span")
                            .html("");
                        // })
                    } else if (className == 'ifa_levels_close') {
                        jQ.get(url,function(data) {
                            $this
                                .removeClass()
                                .addClass("ifa_levels_open")
                                .find("span")
                                .html(data);
                        })
                    }
                    return false;
                }
            })
        })
    }

// Open and Close view_levels
    $.fn.toggleViewLevels = function() {
        return this.each(function() {
            $(this).click(function(event) {
                if (event.target == this) {
                    $this = $(this);
                    var url = $this.find("a").attr("href");
                    var className = $this.attr("class");
                    if (className == 'view_levels_open') {
                        $this
                            .removeClass()
                            .addClass("view_levels_close")
                            .find("span")
                            .html("");
                        // })
                    } else if (className == 'view_levels_close') {
                        jQ.get(url,function(data) {
                            $this
                                .removeClass()
                                .addClass("view_levels_open")
                                .find("span")
                                .html(data);
                        })
                    }
                    return false;
                }
            })
        })
    }



// Open and Close authorization_levels
    $.fn.toggleAuthorizationLevels = function() {
        return this.each(function() {
            $(this).click(function(event) {
                if (event.target == this) {
                    $this = $(this);
                    var url = $this.find("a").attr("href");
                    var className = $this.attr("class");
                    if (className == 'authorization_levels_open') {
                        $this
                            .removeClass()
                            .addClass("authorization_levels_close")
                            .find("span")
                            .html("");
                        // })
                    } else if (className == 'authorization_levels_close') {
                        jQ.get(url,function(data) {
                            $this
                                .removeClass()
                                .addClass("authorization_levels_open")
                                .find("span")
                                .html(data);
                        })
                    }
                    return false;
                }
            })
        })
    }

// add a new reply by ajax.
    $.fn.addNewReply = function(reply_url) {
        return this.each(function() {
            $(this).click(function() {
                var $discussion_reply_form = $(this).parents(".discussion_reply_form");
                var $reply_or_login_warp = $(this).parents(".reply_or_login_warp");
                var $discussion_replys = $reply_or_login_warp.prev('.discussion_replys');
                comment = $discussion_reply_form.find("textarea[name='new_discussion[comment]']").val();
                public_id = $reply_or_login_warp.find("input[name='public_id']").val();
                if (comment.length == 0) {
                    alert("Please enter a comment before submitting.")
                    return false
                } else {
                    $.post(reply_url, {'id':public_id, 'comment':comment}, function(data) {
                        $reply_or_login_warp.find("textarea[name='new_discussion[comment]']").val("");
                        $discussion_replys.html(data);

                        var replies_num =  $discussion_replys.find(".discussion_reply_warp").length;
                        if (replies_num == 1) {
                            replies = replies_num + " reply"
                        } else {
                            replies = replies_num + " replies"
                        }
                        $discussion_replys.find("input[name='last_post_at']").each(function() {
                            last_post_at = $(this).val();
                        })
                        $discussion_replys.parents('.discussion_thread_header ')
                            .find('.iwing_module_title')
                            .find("em")
                            .html(replies)
                            .end()
                            .find("abbr")
                            .html(last_post_at);
                        $(".discussion_reply_warp").changeReplyStatus().addReportAction();
                    });
                    return false
                }
            })
        })
    }

// delete reply and comment by ajax.
    $.fn.deleteCommentAndReply = function() {
        return this.each(function() {
            $(this).click(function() {
                $this = $(this);
                var delete_url = $this.attr("href");
                $.get(delete_url, function(data) {
                    $this.parents(".discusssion_by_same_author").find('div').html(data);
                    $this.parents(".iwing_discussion_description").find('div:first').html(data);
                    $this.parents(".discussion_reply_comment").html(data);
                })
                return false;
            })
        })
    }

// login form submit
    $.fn.lgoinFormSubmit = function(partial, current_topic) {
        return this.each(function() {
            $(this).click(function() {
                var $login_form = $(this).parents("form");
                var login_url = $login_form.attr("action");
                var email_address = $login_form.find("input[name='user[email_address]']").val();
                var password = $login_form.find("input[name='user[password]']").val();
                var authenticity_token = $login_form.find("input[name='authenticity_token']").val();
                if (email_address.length == 0 || password.length == 0)	{
                    alert("Please enter both your username and password.");
                } else {
                    $.post(login_url,
                        {'user[email_address]':email_address,
                            'user[password]':password,
                            'authenticity_token':authenticity_token,
                            'public_id':current_topic,
                            'partial':partial}, null, "script");
                }
                return false
            })
        })
    }

// add action on each reply form cancel button
    $.fn.replyFormCancel = function() {
        return this.each(function() {
            $(this).click(function() {
                $(this).parents(".discussion_reply_form").find("textarea[name='new_discussion[comment]']").val("");
                $(this).parents(".reply_or_login_warp").hide();
                return false;
            })
        })
    }

// make reply ajax login form more usefull
    $.fn.addLoginInputLabel = function() {
        return this.each(function() {
            var $email_address_array = jQ(this).find("input[name='user[email_address]']");
            var $password_array = jQ(this).find("input[name='user[password]']");
            var changeEmailDisable = function() {
                if ($email_address_array.val() == '') { $email_address_array.addClass("disabled_email") }
            }
            var changePasswordDisable = function() {
                if ($password_array.val() == '') { $password_array.addClass("disabled_password") }
            }
            changeEmailDisable();
            changePasswordDisable();
            $email_address_array.focus(function() {
                if (jQ(this).val() == '') {
                    jQ(this).removeClass("disabled_email")
                }
            }).blur(function() { changeEmailDisable() })
            $password_array.focus(function() {
                if (jQ(this).val() == '') {
                    jQ(this).removeClass("disabled_password")
                }
            }).blur(function() { changePasswordDisable() })

        })
    }
// add action on each login form cancel button
    $.fn.ajaxLoginCancel = function(warp_box) {
        return this.each(function() {
            $(this).click(function() {
                $reply_or_login_warp = $(this).parents(warp_box);
                $reply_or_login_warp.find("input[name='user[email_address]']")
                    .addClass("disabled_email").val("")
                $reply_or_login_warp.find("input[name='user[password]']")
                    .addClass("disabled_password").val("")
                $reply_or_login_warp.hide();
                return false;
            })
        })
    }

    $.fn.changeReplyStatus = function() {
        return this.each(function() {
            $(this).hover(function() {
                $(this).find("span.change_status").show();
            }, function() {
                $(this).find("span.change_status").hide();
            })
        })
    }
// add action on each report as links.
    $.fn.addReportAction = function() {
        var url = $("input[name='report_url']").val();
        return this.each(function() {
            var $this = $(this);
            $this.find("a.report").click(function() {
                var abuse = $(this).attr("class");
                var $report_warp = $(this).parents("span");
                var discussion = $this.find("input[name='discussion_public_id']").val();
                $.post(url, {'abuse':abuse, 'id':discussion}, function(data) {
                    $report_warp.html(data).removeClass().addClass("report_successful");
                });
            })
        })
    }

// Associates change 'Member of  The Co-Operative Project'
    $.fn.changeMemberStatus = function(url) {
        function closeAll() {
            jQ(".change_status").each(function() {
                $this = jQ(this);
                if($this.html() == yes_html) {
                    $this.html("Yes");
                } else if ($this.html() == no_html) {
                    $this.html("No");
                } else {}
            })
        }
        function change_member_status(elems, url) {
            elems.each(function() {
                $para_elem = jQ(this).parent(".change_status")
                jQ(this).click(function(event) {
                    jQ.post(url, {'status':jQ(this).val(), 'id':$para_elem.attr("title")}, function(data) {
                        $para_elem.html(data);
                    });
                    event.stopPropagation();
                });
            })
        }
        return this.each(function() {
            $(this).click(function() {
                var content = $(this).text();
                var user = $(this).attr("title");
                closeAll();
                if(content == 'Yes') {
                    var html = yes_html;
                } else {
                    var html = no_html;
                }
                $(this).html(html);
                change_member_status(jQ("input[name='status']"), url);
            })
        })
    };

// image add shadow.
    $.fn.addImageShadow = function() {
        return this.each(function() {
            var $img = $(this).find("img");
            var width = $img.css("width");
            var height = $img.css("height");
            var style = $img.attr("style");

            //DRN added check if any element is null or undefined
            if ((style != null)&&(width != null)&&(height != null)) {
                $img.wrap("<div class='shiftcontainer'><div class='shadowcontainer'></div></div>").attr("style", "").parents('.shiftcontainer').attr("style", style).css({
                    width: width,
                    height: height
                }).end().parents('.shiftcontainer').find(".shadowcontainer").css({
                    width: width,
                    height: height
                });
            }
        })
    }

// segmented control
    $.fn.segmentedControl = function () {
        return this.each(function() {
            var $section_selector = $(this);
            var $active_section = $(".active_section", $section_selector)
            $("div:gt(0)", $section_selector).addClass('border');
            $("div:first", $section_selector).addClass('first').wrapInner("<div></div>");
            $("div:last", $section_selector).addClass('last').wrapInner("<div></div>");
            $("div", $active_section).addClass('active');
            // $("#active_section").css('background-image', '/images/section_selector_bg.png')
        })
    }

    $.fn.addUIStateClass = function() {
        return this.each(function() {
            $(this).hover(
                function(){
                    $(this).addClass("ui-state-hover");
                },
                function(){
                    $(this).removeClass("ui-state-hover");
                }
            ).mousedown(function(){
                    $(this).addClass("ui-state-active");
                })
                .mouseup(function(){
                    $(this).removeClass("ui-state-active");
                });
        })
    };

    $.fn.addChangeAction = function(url) {
        return this.each(function() {
            $(this).click(function() {
                window.location = url;
                return false;
            })
        })
    };

    $.fn.addEditAction = function(url) {
        return this.each(function() {
            $(this).click(function() {
                window.location = url + '/' + $(this).attr("title");
                return false;
            })
        })
    };

    $.fn.addShowAction = function(url) {
        return this.each(function() {
            $(this).click(function() {
                window.location = url + '/'  + $(this).attr("title");
                return false;
            })
        })
    };

})(jQuery);