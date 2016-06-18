

require 'yaml'
class GetData
  def run

puts "enter the following in your
developer console to automate
infinite scroll clicks. Wait until it reaches the end.\n\n"

argument = ARGV.shift
if argument
puts <<-JS
var interval = window.setInterval(function(){
    $(".more.hidden").trigger("click")
}, 250)
JS
else
puts <<-JS
var interval = window.setInterval(function(){
    $('html, body').scrollTop( $(document).height() - $(window).height() );
}, 250)
JS
end
puts "\n\nwhen it is done, enter the following:\n\n "

puts <<-JS
window.clearInterval(interval)
JS

puts "\n\npress enter when done\n\n"
input = gets.chomp

puts "enter the following Javascript:\n\n"

if argument
puts <<-JS
  var $body = $("body");
  $(".text").each(
    function(idx, elem) {
      var $el = $(elem);
      var name = $el.find(".startup-link").text();
      var desc = $el.find(".blurb").text(); var location = $($el.find(".tags a")[0]).text()
      $body.prepend("name: " + name + ",<br>" + "desc: " + desc + "<br>" + "location: " + location + "<br><br>" )
    }
  );
JS
else
puts <<-JS
var $body = $("body");
$(".header-info").each(
  function(idx, elem) {
    var $el = $(elem);
    var name = $el.find(".startup-link").text();
    var desc = $el.find(".tagline").text();
    var jobs = $el.find(".collapsed-listing-row").text();
    $body.prepend("name: " + name + ",<br>" + "desc: " + desc + "<br>" + "jobs: " + jobs + "<br><br>")
  }
);
JS
end

puts "\n\npress enter when done\n\n"
input = gets.chomp

puts "copy the text at the top of the screen to your yaml file and format is appropriately."

end
end