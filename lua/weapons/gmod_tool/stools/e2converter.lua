TOOL.Category		= "Wire Expression2 "
TOOL.Name			= "#PropToHolo"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "PropToHolo_distance" ] 			= "100"

 

if(CLIENT) then
    language.Add( "Tool.e2converter.name", "PropToHolo" )
	language.Add( "Tool.e2converter.desc", "" )
    _dist = 0
    main_panel = nil
    function cl_chat_log( data )
        if(data == nil || data == "") then 
            return 
        end 
        chat.AddText( Color(74,156,179), "[WE2 PtoH]: ", Color(255,255,255) ,  data)
    end
    function _draw_DrawRect( x ,y , w , h  )
        surface.SetDrawColor( 255, 165, 0, 255 )
        surface.DrawRect( x , y, w,h )

    end
    function render_draw_line( minvec1 , maxvec2 )
        render.DrawLine( minvec1, maxvec2, Color( 255, 0, 0, 255 ), true )
    end 

    local pos_ = Vector()
    local angel_ = Angle()
    local _Size = Vector()
    local size_int = 0
    function _daraw_box( ent , color )
        if( ent == nil || !ent:IsValid() ) then 
            return 
        end 
        _Size = (ent:OBBMins() -  ent:OBBMaxs()) / 2 - Vector(2 ,2 ,2)
        render.DrawWireframeBox( ent:GetPos(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs(),color || Color( 255, 255, 255 ),  false )
    end 


    WE2PtoH = WE2PtoH or {}
    WE2PtoH.Props = WE2PtoH.Props or {}
    WE2PtoH.BaseProp = WE2PtoH.BaseProp or nil
    WE2PtoH.Menu = WE2PtoH.Menu or nil
    

    local function FindEnt(pos, rad )
        local t = {}
        for _,ent in pairs( ents.FindByClass( "gmod_wire_hologram" ) ) do
            if( pos:Distance( ent:GetPos() ) < rad ) then 
                table.Add(t, {ent})
            end
        end
        return t
    end
    local function AngleMathRand( ang )
        return Angle(  math.Round( ang[1] ) ,  math.Round( ang[2] ) ,  math.Round( ang[3] )  )
    end
    local function  PosAngToString(p)
        return  p[1]..","..p[2]..","..p[3]
    end

    local function joun(strng_u , table)
        local str_ = ""
        for it, item in pairs(table) do
            str_ = str_ .. item .. strng_u or " "
        end
        return str_
    end
    local function timeToStr( time )
        local tmp = time
        local s = tmp % 60
        tmp = math.floor( tmp / 60 )
        local m = tmp % 60
        tmp = math.floor( tmp / 60 )
        local h = tmp % 24
        tmp = math.floor( tmp / 24 )
        local d = tmp % 7
        local w = math.floor( tmp / 7 )

        return string.format( "%02iw_%id_%02ih_%02im_%02is", w, d, h, m, s )
    end



    function func_PropToHolo_distance( player, tool, args )
        _dist = tonumber(args[1])
       
	end
	concommand.Add( "PropToHolo_distance", func_PropToHolo_distance )

    function func_PropToHolo_convert()
   
        if(WE2PtoH.BaseProp == nil || !WE2PtoH.BaseProp || WE2PtoH.BaseProp:IsWorld()) then 
            cl_chat_log( " Base prop not found!")
            return
        end 
        
        local function changedE2( id , string)
            return 
            [[if( changed(IDload) && IDload ==]] .. id..[[){]] .. "\n" .. string .. "}\n"
        
        end
        

      
        local dir_ = "expression2/E2holoConvert/".. string.Replace(string.Replace(game.GetIPAddress(),".","_"),":","_") 
        local name_file = dir_ .. "/".. os.date( "%H_%M_%S - %d_%m_%Y" , os.time() ) ..".txt"
        file.CreateDir( dir_ )

 
        local E2_code_s =
[[
@name
@inputs
@outputs
@persist [Count]:number [DATA]:table [IDload  Cur IsHolo AllCount CurCount HoloAlpha]:number Local_Entity:entity
#by UnderKo https://vk.com/underko https://steamcommunity.com/id/UnderKo/
interval(100)
if(first()){
    IsHolo = 1
    AllCount = ]] .. table.Count(WE2PtoH.Props) .. [[ 
    HoloAlpha = 1    
    holoCreate(0) 
    holoAng(0,entity():toWorld(ang()))
    holoPos(0,entity():toWorld(vec(0,0,10)))
    holoParent(0,entity()) 
    holoColor(0,vec4(0,0,0,0))
    Local_Entity = holoEntity(0)	 
}

]]

        local E2_code_spawnh = 
[[
if( curtime() > Cur ){ Cur = curtime() + 0.1 IDload++ }
if(!holoEntity(CurCount):isValid()){  
    local Tab = DATA[CurCount , table]     
    if(HoloAlpha){
        Tab[4,vector4][4] = 255
    } 
    holoCreate(CurCount,Local_Entity:toWorld(Tab[1,vector]) , Tab[2,vector], Local_Entity:toWorld(Tab[3,angle]) ,Tab[4,vector4])
    holoParent(CurCount , Local_Entity)
    entity():setName("Holo count: " + CurCount + "/" + AllCount)
}else{
    local Tab = DATA[CurCount , table] 
    holoModel(CurCount,Tab[5,string])     
    if(Tab[6,string] != "null")
    {       
        holoMaterial(CurCount,Tab[6,string])
    }   
}
CurCount++
if( CurCount > AllCount){
    CurCount = 1
}	
]]

        file.Append( name_file,E2_code_s)


        local count = 0
        local push_ = ""
        local id = 0
        
        for it, item in pairs(WE2PtoH.Props) do

            item.entity = item
            item.position = item:GetPos()
            item.Ang =  AngleMathRand(item:GetAngles()   ) 
            item.model = item:GetModel()
            item.material = item:GetMaterial()
            local colo = item:GetColor()
            item.color =  colo["r"] .. "," .. colo["g"] .. "," .. colo["b"] .. "," .. colo["a"]


            local local_position = item.position - WE2PtoH.BaseProp:GetPos()
            if local_position == nill then 
                continue
            end
            local E2_position =  "vec(" .. PosAngToString(local_position) ..  ")"
            local E2_v_scalse =  "vec(1)"
            local E2_Ang    =  "ang("..PosAngToString( item.Ang)..")"
            local E2_color    =  "vec4("..item.color..")"
            local E2_model    = "\"null\""
            local E2_material    = "\"null\""
            if(string.len(item.model or "") >0) then 
                E2_model = "\""..item.model.."\""
            end
            if string.len(item.material) > 0 then
                E2_material = "\""..item.material.."\""
            end


            push_ = push_ .. "  DATA:pushTable(table("..E2_position..","..E2_v_scalse..","..E2_Ang..","..E2_color.."," .. E2_model..","..E2_material.."))" .. "\n"
            

            
            count = count + 1

             
            if( count > 1 ) then 
                push_ = push_ .. "  print(\"Loaded: " .. id .. " \")\n"
                file.Append( name_file, changedE2(id ,push_)) 		
                push_ = ""
                count = 0
                id = id + 1
            end
        end 
        file.Append( name_file,"\n") 
        file.Append( name_file,E2_code_spawnh) 
        chat.AddText(Color(255,255,255) , "[E2]: Save code: " .. name_file)



	end
    function _add_new_entity__( AimEnt )
        if(!table.HasValue( WE2PtoH.Props, AimEnt )) then 
            table.insert( WE2PtoH.Props, AimEnt )
            for i,k in pairs( WE2PtoH.Props) do 
                cl_chat_log(" [ENT] " .. tostring(k))
            end
        end 

    end 

	concommand.Add( "PropToHolo_convert", func_PropToHolo_convert )

    local _vis = false
    function _draw__()
        _vis = !_vis
        if(!_vis) then 
            hook.Remove("PostDrawOpaqueRenderables", "PropToHolo3dBox")
            return 
        end 
       
        hook.Add("PostDrawOpaqueRenderables", "PropToHolo3dBox", function()
            -- if(LocalPlayer():GetTool().Name != "#PropToHolo") then 
            --     return 
            -- end 
            local trace = LocalPlayer():GetEyeTrace()
            local angle = trace.HitNormal:Angle()
                
            for i,k in pairs( WE2PtoH.Props) do 
                
            _daraw_box( k )    
                
            end
            _daraw_box(WE2PtoH.BaseProp , Color(255,0,0) )  

            -- if(input.IsKeyDown( KEY_LSHIFT)) then

            --     render.DrawWireframeBox( trace.HitPos, Angle(), Vector(_dist , _dist , _dist), -Vector(_dist , _dist , _dist) ,  Color( 33, 255, 0 ),  true )
            -- end 

        end)

    end 
    concommand.Add( "PropToHolo_3Dbox", _draw__ )

    function _rebuild_menu( )
       
        WE2PtoH.Menu:ClearControls()
        WE2PtoH.Menu:AddControl( "Label", { Text = "Prop capture distance", Description	= "" }  )
        WE2PtoH.Menu:AddControl( "Slider",  { Label	= "Distance",
					Type	= "Float",
					Min		= 100,
					Max		= 1000,
					Command = "PropToHolo_distance",
					Description = "Distance"}	 )
        WE2PtoH.Menu:AddControl( "Button", { Label = "Convert to E2", Command = "PropToHolo_convert", Description = ""  } )
        WE2PtoH.Menu:AddControl( "Button", { Label = "Draw 3D Box", Command = "PropToHolo_3Dbox", Description = ""  } )
    end 

	concommand.Add( "PropToHolo_RebuildMenu", _rebuild_menu )
    RunConsoleCommand( "PropToHolo_distance", "100")
    cl_chat_log( "Reload menu" )


    
end 
 


function TOOL:LeftClick( trace )
    if(CLIENT) then


         

         
        local AimEnt = trace.Entity
        local AimPos = trace.HitPos
        -- if(input.IsKeyDown( KEY_LSHIFT)) then
           
        --     local table__ = ents.FindInBox( AimPos - Vector(_dist , _dist , _dist), AimPos + Vector(_dist , _dist , _dist) )
        --     print(#table__)
        --     for i,k in pairs( table__ ) do 
        --         _add_new_entity__(k)
        --     end
            
        -- end 

        if(input.IsKeyDown( KEY_LALT)) then 
            if(table.HasValue( WE2PtoH.Props, WE2PtoH.BaseProp )) then 

                table.RemoveByValue( WE2PtoH.Props, WE2PtoH.BaseProp )
            end 
            WE2PtoH.BaseProp = AimEnt
             
        else
            _add_new_entity__(AimEnt)
            
        end 
    
    
    end 

    
 	
end 
function TOOL:Holster( trace, direction )
    //if(SERVER) then return end 
    
end
function TOOL:FreezeMovement()
    
end
function TOOL:RightClick( trace )
    if(SERVER) then return end 


    //RunConsoleCommand( "PropToHolo_convert")
end 
 


function TOOL:Reload( trace )
	if(SERVER) then return end
 
   
    



    if(input.IsKeyDown( KEY_LSHIFT )) then 
        if(table.HasValue( WE2PtoH.Props, trace.Entity )) then 

            table.RemoveByValue( WE2PtoH.Props, trace.Entity )
        end 
        if(WE2PtoH.BaseProp == trace.Entity) then 
            WE2PtoH.BaseProp = nil
        end 
    else    
        WE2PtoH.Props = {}
        WE2PtoH.BaseProp = nil
    end 
    cl_chat_log("Clear all select")
end
function TOOL.BuildCPanel( Panel )
    WE2PtoH.Menu = Panel
    RunConsoleCommand( "PropToHolo_RebuildMenu")
end

 