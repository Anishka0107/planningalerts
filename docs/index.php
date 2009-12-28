<?php 
    require_once ("config.php"); 
    require_once ("user.php");   
    require_once ("stats.php"); 

$index_page = new index_page;

class index_page {

    //Properties
	var $warnings = "";
	var $onloadscript = "";
	var $address = "";
	var $lat = NULL;
	var $lng = NULL;
	var $email = "";
	var $alert_area_size = "m";
	var $email_warn = false;
	var $address_warn = false;	

	//Constructor
	function index_page() {
	
		//check for postback vs load
		if (isset($_POST["_is_postback"])) {
			$this->unbind();
    	    $this->process();
		}else{
		    $this->setup();
			$this->bind();
		}		
	}
	
    //setup
    function setup (){

    }

    function meters_in_words($meters) {
        if ($meters < 1000)
            return $meters . " m";
        else
            return $meters / 1000 . " km";
    }

	//Bind
	function bind() {
	    
		//page vars
		$form_action = $_SERVER['PHP_SELF'];
		$this->onloadscript = "setFocus('txtEmail');";

		//smarty
		$smarty = new Smarty;
        $smarty->force_compile = true;
        $smarty->compile_dir = SMARTY_COMPILE_DIRECTORY;
        
		$smarty->assign("stats", stats::get_stats());
		$smarty->assign("menu_item", "signup");
		$smarty->assign("address", $this->address);
		$smarty->assign("email", $this->email);		
		$smarty->assign("alert_area_size", $this->alert_area_size);		
		$smarty->assign("page_title","Email alerts of planning applications near you");
		$smarty->assign("warnings", $this->warnings);
		$smarty->assign("email_warn", $this->email_warn);		
		$smarty->assign("address_warn", $this->address_warn);	
		
		$smarty->assign("onloadscript", $this->onloadscript);
		$smarty->assign("small_zone_size_in_words", $this->meters_in_words(SMALL_ZONE_SIZE));
		$smarty->assign("medium_zone_size_in_words", $this->meters_in_words(MEDIUM_ZONE_SIZE));
		$smarty->assign("large_zone_size_in_words", $this->meters_in_words(LARGE_ZONE_SIZE));				
		$smarty->assign("small_zone_size", SMALL_ZONE_SIZE);
		$smarty->assign("medium_zone_size", MEDIUM_ZONE_SIZE);
		$smarty->assign("large_zone_size", LARGE_ZONE_SIZE);
		
		//Render
		$smarty->display('index.tpl');
		
	}
	
	function unbind (){

	    //Get postcode and setup the group
	    $this->address = $_POST['txtAddress'];
	    $this->email = $_POST['txtEmail'];	    
	    $this->alert_area_size = $_POST['radAlertAreaSize'];	    
	    
    }
    
    function validate (){
        // Geocode address here - so that we can check its validity and store the result
        $result = address_to_lat_lng($this->address);        
        $this->lat = $result[0];
        $this->lng = $result[1];
        $status_code = $result[2];
        $country_name_code = $result[3];
        $google_address = $result[4];
        $unique = $result[5];
        $accuracy = $result[6];
        
        if($this->email =="" || !valid_email($this->email)){
            $this->email_warn = true;
            $this->warnings .= "Please enter a valid email address.<br/>";            
        }
        if($this->address =="" || $status_code != 200) {
            $this->address_warn = true;
            $this->warnings .= "Please enter a valid street address.<br/>";
        }
        elseif ($country_name_code != "AU") {
            $this->address_warn = true;
            $this->warnings .= "Please enter a valid street address in Australia.<br/>";
        }
        elseif (!$unique) {
            $this->address_warn = true;
            $this->warnings .= "Oops! That's not quite enough information. Please enter a full street address, including suburb and state, e.g. ". $google_address . "<br/>";
        }
        elseif ($accuracy < 6) {
            $this->address_warn = true;
            $this->warnings .= "Oops! We saw that address as \"". $google_address . "\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state.<br/>";
        }
        if($this->alert_area_size != "s" && $this->alert_area_size != "m" && $this->alert_area_size != "l"){
            $this->warnings .= "Please select an area for the alerts.<br/>";
        }
        
        // If there were no problems with geocoding use the format of the address returned
        // by the geocoder as the address. Gives a little more feedback to the user
        if ($this->warnings == "")
            $this->address = $google_address;

        return $this->warnings =="";
        
    }
    
    function process (){
        if($this->validate()){
            
            $user = new user();
            
            //Populate new user
            $user->populate_new($this->email, $this->address, $this->lat, $this->lng, $this->alert_area_size);
            
            //Save 
            $user->save(true);
            
            //send to check mail page
            $base_url = BASE_URL;
            header("Location: {$base_url}/checkmail.php");
        }else{
            $this->bind();
        }
    }
}



?>
