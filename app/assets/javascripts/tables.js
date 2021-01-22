function refill_table( table_id, dados, kind ){
	$( table_id ).empty()
	if ($(table_id+" tbody").length == 0) {
    $(table_id).append("<tbody></tbody>");
	}
	for(i = 0; i < dados.length; i++){
		line = create_line(dados[i], kind)
		$( 'tbody', table_id).append(line)
	}

}

function create_line(dados, kind){
	line = "<tr><td>"+dados[1]+"</td><td>"+dados[2]+"</td><td><div "
	if(kind == "member"){
		line += 'id="director_'+dados[0]+'" class="btn btn-primary">Tornar Diretor' 
		line += '</div></td><td><div id="member_'+dados[0]+'" class="btn btn-primary">Tornar Membro';
	} else {
		line += 'id="member_'+dados[0]+'" class="btn btn-primary">Tornar Membro';
	}
	line += "</div></td></tr>"
	return line
}