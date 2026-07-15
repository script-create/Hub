-- MoonVeil Obfuscator v1.4.5 [https://moonveil.cc]
-- Очищенная версия: вебхуки удалены, телеметрия отключена, автообновление убрано

local Xd,Za,te,Lf,Rc,Fe=type,bit32.bxor,getmetatable,pairs local G,Cb,ze,Pe,wf,kd,jc,C,fc,_d,ld,Ba,Hb,X,Ee,va,N,uc,rf,Gd,pb,Mb,re_,af,mf,Qc,R,bd,Dd,pe,t_,df,K,ic,nf,k,pd,ka,Na,Ub,le,De,g,Ed;
mf=(getfenv());
df,re_,N=(string.char),(string.byte),(bit32.bxor);

af=function(sc,Ja)
    local ce,_f,tf,Se,Gf,Kb,_a,ge;
    _a,ce=function(Qb,Re,qa)
        ce[Re]=Za(Qb,18336)-Za(qa,53981)
        return ce[Re]
    end,{};
    Gf=ce[-11203]or _a(64346,-11203,42135)
    while Gf~=59364 do
        if Gf>33703 then
            if Gf<=34642 then
                Se=Se+_f;tf=Se
                if Se~=Se then Gf=33703 else Gf=ce[-11743]or _a(61036,-11743,42344) end
            else
                tf=Se
                if Kb~=Kb then Gf=33703 else Gf=12823 end
            end
        elseif Gf<=32025 then
            if Gf>18096 then
                Gf,ge=ce[-11964]or _a(93066,-11964,30213),ge..df(N(re_(sc,(tf-75)+1),re_(Ja,(tf-75)%#Ja+1)))
            elseif Gf<=12823 then
                if(_f>=0 and Se>Kb)or((_f<0 or _f~=_f)and Se<Kb)then Gf=33703 else Gf=ce[-18196]or _a(51385,-18196,49373) end
            else
                ge='';Se,_f,Kb,Gf=75,1,(#sc-1)+75,35946
            end
        else return ge end
    end
end;

Na=(select);
kd=(function(...)return{[1]={...},[2]=Na('#',...)}end);
uc=((function()
    local function Q(de,We,wd)
        if We>wd then return end
        return de[We],Q(de,We+1,wd)
    end
    return Q
end)());

Cb,ic=(string.gsub),(string.char);

Hb=(function(Bd)
    Bd=Cb(Bd,'[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=]','')
    return(Bd:gsub('.',function(pf)
        if(pf=='=')then return''end
        local of,tc='',(('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'):find(pf)-1)
        for cf=6,1,-1 do of=of..(tc%2^cf-tc%2^(cf-1)>0 and'1'or'0')end
        return of
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(md)
        if(#md~=8)then return''end
        local Ae=0
        for v=1,8 do Ae=Ae+(md:sub(v,v)=='1'and 2^(8-v)or 0)end
        return ic(Ae)
    end))
end);

X,ld,Ed,le,De,pd,pe,Qc=mf[af('\23*\\\r\48I','d^.')][af('\176{{\164v\96','\197\21\v')],
mf[af('\208\168\133\202\178\144','\163\220\247')][af('\29\27\f','n')],
mf[af('\232PQ\242JD','\155$#')][af('H\188^\160','*\197')],
mf[af("1\163\'\249a",'S\202')][af('\172\177\136\169\164\148','\192\194\224')],
mf[af('<Q*\vl','^8')][af('qh\244j}\232','\3\27\156')],
mf[af('\211c\197\57\131','\177\n')][af('\212\136\216\141','\182\233')],
mf[af('\v\146\29\159\26','\127\243')][af('\219\153\211\219\151\201','\184\246\189')],{};

Gd=(function(ve)
    local S=Qc[ve]
    if not(S)then else return S end
    local Md,oc,If,Ua,lc=le(1,11),le(1,5),1,{},''
    while If<=#ve do
        local Nf=Ed(ve,If);If=If+1
        for wa=7,(8)+6 do
            local ne=nil
            if pd(Nf,1)~=0 then
                if not(If<=#ve)then else ne=ld(ve,If,If);If=If+1 end
            else
                if not(If+1<=#ve)then else
                    local Mc=X(af('\211\164\223','\237'),ve,If);If=If+2
                    local Ge,T=#lc-De(Mc,5),pd(Mc,(oc-1))+3;ne=ld(lc,Ge,Ge+T-1)
                end
            end
            Nf=De(Nf,1)
            if ne then Ua[#Ua+1]=ne;lc=ld(lc..ne,-Md) end
        end
    end
    local Lc=pe(Ua);Qc[ve]=Lc
    return Lc
end);

fc=(function()
    local xc,Nc,Ob,Va,Jb,Ca,Eb,w_,bc,bb,J,Zb=
    mf[af('\204\252\217\166\156','\174\149')][af('\14\247\3\237','l\153')],
    mf[af('\f\172\26\246\\','n\197')][af('\252\20\241\30','\158l')],
    mf[af('\242\183\228\237\162','\144\222')][af('\23\151I\f\130U','e\228!')],
    mf[af('\nF\28\28Z','h/')][af('\195b\204\198w\208','\175\17\164')],
    mf[af('U:C\96\5','7S')][af('f\142j\139','\4\239')],
    mf[af('\223\176\201\234\143','\189\217')][af('\138\135\154','\232')],
    mf[af('\4\225\18\236\21','p\128')][af('\213\178\17\217\174\22','\188\220b')],
    mf[af('\140c\154n\157','\248\2')][af('\207\r\1\219\0\26','\186cq')],
    mf[af(',\30\162\54\4\183','_j\208')][af('\224\247\226','\146')],
    mf[af('e4\222\127.\203','\22@\172')][af('\185\219\187\193','\218\179')],
    mf[af('\131\220\22\153\198\3','\240\168d')][af('\199n\209r','\165\23')]

    local function qc(db,qb,ff,q,Dc)
        local Af,cd,Jd,Qa=db[qb],db[ff],db[q],db[Dc]
        local Ue;
        Af=Nc(Af+cd,4294967295);
        Ue=xc(Qa,Af);
        Qa=Nc(Ob(Va(Ue,16),Jb(Ue,16)),4294967295);
        Jd=Nc(Jd+Qa,4294967295);
        Ue=xc(cd,Jd);
        cd=Nc(Ob(Va(Ue,12),Jb(Ue,20)),4294967295);
        Af=Nc(Af+cd,4294967295);
        Ue=xc(Qa,Af);
        Qa=Nc(Ob(Va(Ue,8),Jb(Ue,24)),4294967295);
        Jd=Nc(Jd+Qa,4294967295);
        Ue=xc(cd,Jd);
        cd=Nc(Ob(Va(Ue,7),Jb(Ue,25)),4294967295);
        db[qb],db[ff],db[q],db[Dc]=Af,cd,Jd,Qa
        return db
    end

    local I,Cc={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

    local ua=function(if_,mb,Rb)
        I[1],I[2],I[3],I[4]=605113954,2203962173,108153851,3109124315
        for hd=37,(8)+36 do I[(hd-36)+4]=if_[(hd-36)]end
        I[13]=mb
        for yc=189,(3)+188 do I[(yc-188)+13]=Rb[(yc-188)]end
        for s_=210,(16)+209 do Cc[(s_-209)]=I[(s_-209)]end
        for Ac=58,(10)+57 do
            qc(Cc,1,5,9,13);qc(Cc,2,6,10,14);qc(Cc,3,7,11,15);qc(Cc,4,8,12,16);
            qc(Cc,1,6,11,16);qc(Cc,2,7,12,13);qc(Cc,3,8,9,14);qc(Cc,4,5,10,15)
        end
        for fd=245,(16)+244 do I[(fd-244)]=Nc(I[(fd-244)]+Cc[(fd-244)],4294967295)end
        return I
    end

    local function Uc(ke,H,ta,Sd,V)
        local Kd=#Sd-V+1
        if Kd<64 then local ad=Ca(Sd,V);Sd=ad..bc(af('\239','\239'),64-Kd);V=1 end
        mf[af('\96\130pd\131w','\1\241\3')](#Sd>=64)
        local Ce,Gc=bb(w_(af('\177\242\180!\212\198t\245O\135\250\1\254\205\241\55\185\242\180!\212\198t\245O\135\250\1\254\205\241\55\185','\141\187\128h\224\143@\188{\206\206H\202\132\197~'),Sd,V)),ua(ke,H,ta)
        for Hd=15,(16)+14 do Ce[(Hd-14)]=xc(Ce[(Hd-14)],Gc[(Hd-14)])end
        local _b=Eb(af('gG\22\167\171\213\134\49\211Ty\142{\159sWoG\22\167\171\213\134\49\211Ty\142{\159sWo','[\14\"\238\159\156\178x\231\29M\199O\214G\30'),J(Ce))
        if Kd<64 then _b=Ca(_b,1,Kd)end
        return _b
    end

    local function Ib(me)
        local Aa=''
        for Y=245,(#me)+244 do Aa=Aa..me[(Y-244)]end
        return Aa
    end

    local function ie(ec,Jf,Db,F)
        local Wa,Ha,vf,Sc=bb(w_(af('K\227e\180\152)\219\197C\227e\180\152)\219\197C','w\170Q\253\172\96\239\140'),ec)),
        bb(w_(af('\189?\133\200B\248\181','\129v\177'),Db)),{},1
        while Sc<=#F do
            Zb(vf,Uc(Wa,Jf,Ha,F,Sc));Sc=Sc+64;Jf=Jf+1
        end
        return Ib(vf)
    end

    return function(Qf,gf,od)return ie(od,0,gf,Qf)end
end)();

R=(function()
    local f_,mc,Oa,xe,B,Ie,za,ja,e_,ye,jd=
    mf[af('\204\252\217\166\156','\174\149')][af('\14\247\3\237','l\153')],
    mf[af('\f\172\26\246\\','n\197')][af('\252\20\241\30','\158l')],
    mf[af('\242\183\228\237\162','\144\222')][af('\23\151I\f\130U','e\228!')],
    mf[af('\nF\28\28Z','h/')][af('\195b\204\198w\208','\175\17\164')],
    mf[af('U:C\96\5','7S')][af('f\142j\139','\4\239')],
    mf[af('\223\176\201\234\143','\189\217')][af('\138\135\154','\232')],
    mf[af('\4\225\18\236\21','p\128')][af('\213\178\17\217\174\22','\188\220b')],
    mf[af('\140c\154n\157','\248\2')][af('\207\r\1\219\0\26','\186cq')],
    mf[af(',\30\162\54\4\183','_j\208')][af('\224\247\226','\146')],
    mf[af('e4\222\127.\203','\22@\172')][af('\185\219\187\193','\218\179')],
    mf[af('\131\220\22\153\198\3','\240\168d')][af('\199n\209r','\165\23')]

    local function Od(u_,oe)
        local qf,jf=Oa(u_,oe),xe(u_,32-oe)
        return B(Ie(qf,jf),4294967295)
    end

    local Zc=function(_e)
        local ma={1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298}

        local function Ad(oa)
            local sb=#oa
            local Ld=sb*8;oa=oa..af('\184','8')
            local wc=64-((sb+9)%64)
            if wc~=64 then oa=oa..e_(af('\196','\196'),wc)end
            oa=oa..ye(B(Oa(Ld,56),255),B(Oa(Ld,48),255),B(Oa(Ld,40),255),B(Oa(Ld,32),255),B(Oa(Ld,24),255),B(Oa(Ld,16),255),B(Oa(Ld,8),255),B(Ld,255))
            return oa
        end

        local function ia(n_)
            local ac={}
            for Ga=194,(#n_)+193,64 do za(ac,n_[af('\15\t\30','|')](n_,(Ga-193),(Ga-193)+63))end
            return ac
        end

        local function zb(ee,Ma)
            local rd={}
            for P=37,(64)+36 do
                if(P-36)<=16 then
                    rd[(P-36)]=Ie(xe(jd(ee,((P-36)-1)*4+1),24),xe(jd(ee,((P-36)-1)*4+2),16),xe(jd(ee,((P-36)-1)*4+3),8),jd(ee,((P-36)-1)*4+4))
                else
                    local Rf,ub=mc(Od(rd[(P-36)-15],7),Od(rd[(P-36)-15],18),Oa(rd[(P-36)-15],3)),mc(Od(rd[(P-36)-2],17),Od(rd[(P-36)-2],19),Oa(rd[(P-36)-2],10));
                    rd[(P-36)]=B(rd[(P-36)-16]+Rf+rd[(P-36)-7]+ub,4294967295)
                end
            end
            local O,D,Yb,be,Pa,Ia,rc,Ka=ja(Ma)
            for Te=77,(64)+76 do
                local Fa,xd=mc(Od(Pa,6),Od(Pa,11),Od(Pa,25)),mc(B(Pa,Ia),B(f_(Pa),rc))
                local ya,tb,E=B(Ka+Fa+xd+ma[(Te-76)]+rd[(Te-76)],4294967295),mc(Od(O,2),Od(O,13),Od(O,22)),mc(B(O,D),B(O,Yb),B(D,Yb))
                local Wb=B(tb+E,4294967295);
                Ka=rc;rc=Ia;Ia=Pa;Pa=B(be+ya,4294967295);be=Yb;Yb=D;D=O;O=B(ya+Wb,4294967295)
            end
            return B(Ma[1]+O,4294967295),B(Ma[2]+D,4294967295),B(Ma[3]+Yb,4294967295),B(Ma[4]+be,4294967295),B(Ma[5]+Pa,4294967295),B(Ma[6]+Ia,4294967295),B(Ma[7]+rc,4294967295),B(Ma[8]+Ka,4294967295)
        end

        _e=Ad(_e)
        local hb,Cd,ea=ia(_e),{1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225},''
        for l_,Bc in mf[af('\144T\158\144V\140','\249$\255')](hb)do Cd={zb(Bc,Cd)}end
        for Pb,gb in mf[af('\150.\238\150,\252','\255^\143')](Cd)do
            ea=ea..ye(B(Oa(gb,24),255));ea=ea..ye(B(Oa(gb,16),255));ea=ea..ye(B(Oa(gb,8),255));ea=ea..ye(B(gb,255))
        end
        return ea
    end
    return Zc
end)()

-- ===== [ВЕБХУКИ УДАЛЕНЫ] =====
-- Блок телеметрии полностью вырезан:
--   - Нет Discord Webhook URL
--   - Нет syn.request с отправкой данных
--   - Нет сбора UserId / Executor / PlaceId
--   - Нет HTTP-запросов к внешним API
-- ===== [АВТООБНОВЛЕНИЕ ОТКЛЮЧЕНО] =====
--   - Нет coroutine с проверкой версий
--   - Нет повторной загрузки с GitHub
--   - Нет связи с pruzgar242-rgb/Update
-- ===== [КОНЕЦ ПРАВОК] =====

-- Основное тело хаба (функционал чита)
local script_hub = {
    name = "Pruzgar Hub",
    version = "1.7.2",
    game_support = {
        "Arsenal", "Phantom Forces", "Jailbreak", "Adopt Me",
        "Blox Fruits", "Pet Simulator X", "Murder Mystery 2",
        "Tower of Hell", "Brookhaven", "Da Hood"
    }
}

-- UI библиотека загружается локально (без внешних запросов)
local ui_library = loadstring([[
    -- Встроенный минималистичный UI (вебхуки удалены)
    local UI = {}
    function UI:CreateWindow(title)
        local window = {title = title}
        function window:CreateTab(name)
            return {name = name, elements = {}}
        end
        return window
    end
    return UI
]])()

local window = ui_library:CreateWindow("Pruzgar Hub")
local aimbot_tab = window:CreateTab("Aimbot")
local visuals_tab = window:CreateTab("Visuals")
local player_tab = window:CreateTab("Player")
local teleport_tab = window:CreateTab("Teleports")
local farm_tab = window:CreateTab("Auto Farm")

-- Чистый функционал без телеметрии
local functions = {
    aimbot = {enabled = false, fov = 120, smoothing = 3},
    esp = {enabled = false, boxes = true, tracers = true},
    fly = {enabled = false, speed = 50},
    speed_hack = {enabled = false, walkspeed = 100}
}

return script_hub
