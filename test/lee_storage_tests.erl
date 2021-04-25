-module(lee_storage_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("lee/include/lee.hrl").

patch() ->
    [ {set, [foo, bar], 1}
    , {set, [bar, baz], 2}
    , {set, [baz, {1}, foo], 1}
    , {set, [baz, {1}, bar], 1}
    , {set, [baz, {2}, foo], 1}
    , {set, [baz, {2}, bar], 1}
    , {set, [quux, {1}, foo, {1}], 11}
    , {set, [quux, {1}, foo, {2}], 1}
    ].

patch2() ->
    [ {rm, [foo, bar]}
    , {rm, [baz, {1}]}
    , {rm, [quux, {1}, foo, {1}]}
    , {rm, [quux, {1}, foo, {2}]}
    ].

get_test() ->
    Data0 = lee_storage:new(lee_map_storage),
    Data = lee_storage:patch(Data0, patch()),
    ?assertMatch({ok, 1}, lee_storage:get([foo, bar], Data)),
    ?assertMatch({ok, 2}, lee_storage:get([bar, baz], Data)),
    ?assertMatch({ok, 11}, lee_storage:get([quux, {1}, foo, {1}], Data)),
    ?assertMatch(undefined, lee_storage:get([quux, {1}, foo, {3}], Data)).

list_test() ->
    Data0 = lee_storage:new(lee_map_storage),
    Data = lee_storage:patch(Data0, patch()),
    %% Patterns that don't contain ?children should be just returned
    %% back:
    ?assertMatch([[foo, bar]], lee_storage:list([foo, bar], Data)),
    ?assertMatch([[baz]], lee_storage:list([baz], Data)),
    ?assertMatch( [[quux, {1}, foo]]
                , lee_storage:list([quux, {1}, foo], Data)
                ),
    %% Single ?children in a pattern:
    ?assertMatch( [ [baz, {1}]
                  , [baz, {2}]
                  ]
                , lee_storage:list([baz, ?children], Data)
                ),
    ?assertMatch( [[quux, {1}]]
                , lee_storage:list([quux, ?children], Data)
                ),
    %% Add normal key after ?children:
    ?assertMatch( [ [baz, {1}, foo]
                  , [baz, {2}, foo]
                  ]
                , lee_storage:list([baz, ?children, foo], Data)
                ),
    %% Child instance in the pattern:
    ?assertMatch( [ [quux, {1}, foo, {1}]
                  , [quux, {1}, foo, {2}]
                  ]
                , lee_storage:list([quux, {1}, foo, ?children], Data)
                ),
    %% Multiple ?children in the pattern:
    ?assertMatch( [ [quux, {1}, foo, {1}]
                  , [quux, {1}, foo, {2}]
                  ]
                , lee_storage:list([quux, ?children, foo, ?children], Data)
                ),
    %% Missing key:
    ?assertMatch( []
                , lee_storage:list([quux, {2}, foo, ?children], Data)
                ).

get_after_delete_test() ->
    Data0 = lee_storage:new(lee_map_storage),
    Data1 = lee_storage:patch(Data0, patch()),
    Data = lee_storage:patch(Data1, patch2()),
    %% Check that simple key gets deleted:
    ?assertMatch(undefined, lee_storage:get([foo, bar], Data)),
    ?assertMatch(undefined, lee_storage:get([quux, {1}, foo, {1}], Data)),
    ?assertMatch(undefined, lee_storage:get([quux, {1}, foo, {3}], Data)),
    %% Check recursive deleteions:
    ?assertMatch(undefined, lee_storage:get([baz, {1}, foo], Data)),
    ?assertMatch(undefined, lee_storage:get([baz, {1}, bar], Data)),
    %% But the rest of data is left (more or less) intact
    ?assertMatch({ok, 2}, lee_storage:get([bar, baz], Data)),
    ?assertMatch({ok, 1}, lee_storage:get([baz, {2}, foo], Data)),
    ?assertMatch({ok, 1}, lee_storage:get([baz, {2}, bar], Data)).

list_after_delete_test() ->
    Data0 = lee_storage:new(lee_map_storage),
    Data1 = lee_storage:patch(Data0, patch()),
    Data = lee_storage:patch(Data1, patch2()),
    %% Single ?children in a pattern:
    ?assertMatch( [[baz, {2}]]
                , lee_storage:list([baz, ?children], Data)
                ),
    ?assertMatch( [[quux, {1}]]
                , lee_storage:list([quux, ?children], Data)
                ),
    ?assertMatch( []
                , lee_storage:list([quux, ?children, foo, ?children], Data)
                ).

fold_test() ->
    Data0 = lee_storage:new(lee_map_storage),
    Data = lee_storage:patch(Data0, patch()),
    Count = length(patch()),
    ?assertMatch( Count
                , lee_storage:fold( fun(_Key, _Val, Acc) ->
                                            Acc + 1
                                    end
                                  , 0
                                  , Data
                                  )
                ).

fold_after_delete_test() ->
    Data0 = lee_storage:new(lee_map_storage),
    Data1 = lee_storage:patch(Data0, patch()),
    Data = lee_storage:patch(Data1, patch2()),
    Count = length(patch()) - 5,
    ?assertMatch( Count
                , lee_storage:fold( fun(_Key, _Val, Acc) ->
                                            Acc + 1
                                    end
                                  , 0
                                  , Data
                                  )
                ).

dump_test() ->
    Data0 = lee_storage:new(lee_map_storage),
    Data1 = lee_storage:patch(Data0, patch()),
    ?assertEqual( lists:sort(patch())
                , lists:sort(lee_storage:dump(Data1))
                ),
    Data2 = lee_storage:clone(Data1, lee_map_storage, #{}),
    ?assertEqual( lists:sort(patch())
                , lists:sort(lee_storage:dump(Data2))
                ).
