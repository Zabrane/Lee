-module(lee_os_env).

-export([ metamodel/0
        , read/1
        , read_to/2
        , document_values/1
        ]).

-include_lib("lee/src/framework/lee_internal.hrl").

-define(metatype, os_env).

-spec metamodel() -> lee:lee_module().
metamodel() ->
    #{ metatype =>
           #{ ?metatype =>
                  {[metatype]
                  , #{ doc_chapter_title => "OS Environment Variables"
                     , doc_gen           => fun ?MODULE:document_values/1
                     }
                  }
            }
     }.

%% @doc Make a patch from OS environment variables
%% @throws {error, string()}
-spec read(lee:model()) -> lee:patch().
read(Model) ->
    EnvVars = lee_model:get_metatype_index(?metatype, Model),
    lists:foldl( fun(Key, Acc) ->
                         read_val(Model, Key, Acc)
                 end
               , []
               , EnvVars).

%% @doc Make a patch from OS environment variables and apply it to
%% data
%% @throws {error, string()}
-spec read_to(lee:model(), lee_storage:data()) -> lee_storage:data().
read_to(Model, Data) ->
    Patch = read(Model),
    lee_storage:patch(Data, Patch).

read_val(Model, Key, Acc) ->
    #mnode{metaparams = Attrs} = lee_model:get(Key, Model),
    EnvVar = ?m_attr(?metatype, os_env, Attrs),
    case os:getenv(EnvVar) of
        false ->
            Acc;
        Value0 ->
            case lee:from_string(Model, Key, Value0) of
                {ok, Value} ->
                    [{set, Key, Value} | Acc];
                {error, _} = Error ->
                    throw(Error)
            end
    end.

-spec document_values(lee:model()) -> xmerl:document().
document_values(Model) ->
    #model{meta_class_idx = Idx} = Model,
    Keys = maps:get(?metatype, Idx, []),
    Fun = fun(Key) ->
                  #mnode{metaparams = Attrs} = lee_model:get(Key, Model),
                  Oneliner = ?m_valid(value, maps:get(oneliner, Attrs, "")),
                  EnvVar = ?m_attr(?metatype, os_env, Attrs),
                  {section, [{id, EnvVar}]
                  , [ {title, [EnvVar]}
                    , {para, [Oneliner, lee_doc:xref_key(Key)]}
                    ]
                  }
          end,
    Intro = "<para>The following OS environment variables are used to
             set configuration values. Values of type string() are
             taken from OS environment variables verbatim, other types
             are parsed as Erlang terms.</para>",
    lee_doc:docbook(Intro) ++ lists:map(Fun, Keys).
