%%%-------------------------------------------------------------------
%%% File    : sherk_tab.erl
%%% Author  : Mats Cronqvist <locmacr@mwlx084>
%%% Description : 
%%%
%%% Created : 21 Aug 2006 by Mats Cronqvist <locmacr@mwlx084>
%%%-------------------------------------------------------------------
-module(sherk_tab).

-export([assert/1,check_file/1]).
-import(filename,[dirname/1,join/1]).

assert(File) ->
    try 
	%% we have a table
	File = panEts:lup(sherk_prof, file)
    catch 
	_:_ -> 
	    %% we need a table
	    TabFile = join([dirname(File),"sherk_prof.ets"]),
	    case file:read_file_info(TabFile) of
		{ok,_} -> 
		    %% we have a tab file squirreled away
		    panEts:f2t(TabFile);
		{error,_} -> 
		    %% make tab and save it
		    sherk_scan:action(File,'',sherk_prof,0,''),
		    ets:foldl(fun store_pid/2, [], sherk_prof),
		    ets:insert(sherk_prof, {file, File}),
		    catch panEts:t2f(sherk_prof,TabFile)
	    end
    end.

store_pid({{{pid,time},P},_},_) -> ets:insert(sherk_prof,{pid_to_list(P),P});
store_pid(_,_) -> ok.

check_file(File) -> ".trc" = filename:extension(File).
