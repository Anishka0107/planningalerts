<?php 
    require_once ("config.php"); 
    require_once ("stats.php"); 
            
$api = new api;

class api {

	//Constructor
	function api() {
		$this->bind();
	}

    // Turn a url for an API call into a Google Map of that data
    function mapify($url) {
        return "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=13&om=1&q=" . urlencode($url);
    }
    
	//howto
	function bind() {
		$form_action = $_SERVER['PHP_SELF'];

		$smarty = new Smarty;
		$smarty->force_compile = true;
		$smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
		$smarty->assign("stats", stats::get_stats());
		$smarty->assign("page_title","API");
		$smarty->assign("menu_item","api");
		
		$example_address = "24 Bruce Road Glenbrook, NSW 2773";
		$example_lat = 51.52277;
		$example_lng = -0.067281;
		$example_size = 4000;
		$example_bottom_left_lat = 51.52277;
		$example_bottom_left_lng = -0.067281;
		$example_top_right_lat = 52.52277;
		$example_top_right_lng = 15;
		$example_authority = "Blue Mountains";
		
		$api_base = BASE_URL . "/api.php";
		$api_example_address_url = $api_base . "?call=address&address=" . urlencode($example_address) .
		    "&area_size=" . $example_size;
        $api_example_latlong_url = $api_base . "?call=point&lat=" . $example_lat . "&lng=" . $example_lng .
            "&area_size=" . $example_size;
        $api_example_area_url = $api_base . "?call=area&bottom_left_lat=" . $example_bottom_left_lat .
            "&bottom_left_lng=" . $example_bottom_left_lng . "&top_right_lat=" . $example_top_right_lat .
            "&top_right_lng=" . $example_top_right_lng;
        $api_example_authority_url = $api_base . "?call=authority&authority=" . urlencode($example_authority);
        
		$smarty->assign("api_example_address_url", $api_example_address_url);
		$smarty->assign("api_example_latlong_url", $api_example_latlong_url);
        $smarty->assign("api_example_area_url", $api_example_area_url);
        $smarty->assign("api_example_authority_url", $api_example_authority_url);

        $smarty->assign("map_example_address_url", $this->mapify($api_example_address_url));
        $smarty->assign("map_example_latlong_url", $this->mapify($api_example_latlong_url));
        $smarty->assign("map_example_area_url", $this->mapify($api_example_area_url));
        $smarty->assign("map_example_authority_url", $this->mapify($api_example_authority_url));
        
		$smarty->display('apihowto.tpl');
	}

}



?>
