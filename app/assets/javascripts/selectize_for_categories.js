//= require jquery
//= require selectize
//$(document).on("turbolinks:load",function(){
	var $select = $(".selectize").selectize({
		plugins: ['remove_button'],
		persist: false,
		maxItems: null,
		valueField: 'id',
		searchField: 'name'
	});
	var selectize = $select[0].selectize;
