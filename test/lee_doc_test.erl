-module(lee_doc_test).

-include_lib("eunit/include/eunit.hrl").

-include("lee.hrl").

model() ->
    Model = #{ foo =>
                   {[value],
                    #{ oneliner => "This parameter controls fooing"
                     , type     => typerefl:string()
                     , default  => "foo"

                     , doc => "
<para>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce
convallis nibh vel consectetur consequat. Nunc vitae ex eu lorem
vulputate bibendum vel quis nibh. Maecenas vulputate purus a tincidunt
bibendum. Proin scelerisque ligula elementum leo auctor, et accumsan
velit pellentesque. Orci varius natoque penatibus et magnis dis
parturient montes, nascetur ridiculus mus. Proin convallis rutrum
lorem, ut facilisis lectus consectetur sed. Cras in ullamcorper
eros. Praesent quis dui quis arcu condimentum viverra quis dapibus
ex. Integer ultricies laoreet nulla, vitae mollis sem tristique
a. Maecenas in turpis eu odio sodales pellentesque vitae sed sem. Cras
in ullamcorper diam.</para>

<para>Aliquam auctor sed ante eu pellentesque. Suspendisse tincidunt
elit sit amet fringilla sollicitudin. Quisque finibus metus quis ipsum
semper, in consectetur justo tincidunt. Nunc lacinia lorem vitae
condimentum consequat. Nam egestas ut mi vel porttitor. Proin tempus
magna quis nulla feugiat, et blandit massa tristique. Donec ut eros
massa. Cras ac gravida purus, ut rhoncus tellus. Praesent nec eros
pellentesque, varius nisl vitae, auctor magna.</para>

<para>Etiam varius nisi ut aliquam tempus. Sed tempor, magna id
blandit egestas, augue erat sollicitudin sem, ac condimentum lorem
eros ut ante. Ut odio risus, mattis sed vulputate nec, semper ac
nulla. Aliquam mollis tincidunt mi quis volutpat. Lorem ipsum dolor
sit amet, consectetur adipiscing elit. Etiam nisi odio, auctor quis
sem quis, egestas placerat ipsum. Vivamus est orci, tempor cursus
feugiat vel, fermentum et est. Etiam non nunc ac ex viverra aliquet ac
et lectus. Aliquam sodales fermentum odio, in tincidunt elit aliquam
id. Etiam id neque sed felis scelerisque vestibulum. Quisque non magna
justo. Orci varius natoque penatibus et magnis dis parturient montes,
nascetur ridiculus mus. Nulla convallis dapibus imperdiet. Nam
vehicula pharetra ipsum in laoreet.<xref linkend=\"[foo]\"/></para>

<para>Donec erat massa, molestie et auctor vel, commodo vel orci. Nam
sollicitudin sit amet ligula vitae bibendum. Nam sed sem vehicula,
auctor velit ac, euismod metus. Mauris ultrices quam non massa
sagittis, ut rutrum quam interdum. <emphasis>Aenean varius rhoncus
turpis nec convallis.</emphasis> Duis sodales sodales
tempus. Vestibulum id ante sodales justo ornare sagittis. Nunc vitae
ornare diam, nec mattis mi.</para>

<para>Sed nunc justo, dignissim quis aliquam non, suscipit et
orci. Curabitur mollis magna ac nunc mattis, sed condimentum felis
iaculis. Mauris sollicitudin, nisl nec auctor rhoncus, ipsum lacus
finibus leo, efficitur facilisis ex nisi vel ipsum. Sed tempor ornare
efficitur. Aliquam erat volutpat. Nulla sit amet euismod turpis. Nunc
rutrum ex sit amet ligula consequat, a lobortis purus
dignissim. Curabitur dolor ante, mollis at malesuada semper, semper
quis arcu. Curabitur in purus fermentum, suscipit diam eleifend,
dictum augue. Pellentesque bibendum nisi sit amet aliquet
accumsan. Donec non justo in ex vehicula posuere vel ut purus. Aenean
vestibulum nulla at ante ultricies bibendum. Aliquam erat
volutpat. Integer pellentesque sit amet felis viverra
imperdiet. Pellentesque dapibus ipsum in magna ultrices
consectetur. Suspendisse non est ex.</para>"
                     }}
             , bar =>
                   {[value, os_env],
                    #{ oneliner => "This parameter controls baring"
                     , type     => {typerefl:nonempty_list([]), typerefl:iolist()}
                     , os_env   => "BAR"
                     }}
             },
    {ok, Mod} = lee_model:compile( [ lee:base_metamodel()
                                   , lee_os_env:metamodel()
                                   ]
                                 , [Model]
                                 ),
    Mod.


export_test() ->
    lee_doc:make_doc(model(), "My application", [os_env, value], "foo.xml"),
    [io:put_chars(
       os:cmd("pandoc -o foo." ++ Fmt ++
              " --toc -sf docbook -t " ++ Fmt ++" foo.xml"))
     || Fmt <- ["html", "man", "texinfo"]
    ].
