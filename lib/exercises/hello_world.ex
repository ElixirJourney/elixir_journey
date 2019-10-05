defmodule ElixirJourney.Excercise.HelloWorld do

  @moduledoc ~S"""

  Write a small journey that prints the text "HELLO WORLD" to the console (:stdio).

  ----------------------------------------------------------------------
  ## HINTS

  To make an Elixir program, create a new file with a `.exs` extension and start writing your first Jorney. Execute your program by running it with the `elixir` command. e.g.:

  ```sh
  $ elixir hello.exs
  ```

  You can write to the console using the IO module.

  ```elixir
  IO.puts("text")
  ```

  When you are done, you must run:

  ```sh
  $ {journey_name} verify program.exs
  ```

  to proceed. Your program will be tested, a report will be generated, and the Journey will be marked 'completed' if you are successful.

  The `Gettext` module provides a
  [gettext](https://www.gnu.org/software/gettext/)-based API for working with
  internationalized applications.
  ## Using Gettext
  To use `Gettext`, a module that calls `use Gettext` has to be defined:
      defmodule MyApp.Gettext do
        use Gettext, otp_app: :my_app
      end
  This automatically defines some macros in the `MyApp.Gettext` module.
  Here are some examples:
      import MyApp.Gettext
      # Simple translation
      gettext "Here is the string to translate"
      # Plural translation
      ngettext "Here is the string to translate",
               "Here are the strings to translate",
               3
      # Domain-based translation
      dgettext "errors", "Here is the error message to translate"
  Translations are looked up from `.po` files. In the following sections we will
  explore exactly what are those files before we explore the "Gettext API" in
  detail.
  ## Translations
  Translations are stored inside PO (Portable Object) files, with a `.po`
  extension. For example, this is a snippet from a PO file:
      # This is a comment
      msgid "Hello world!"
      msgstr "Ciao mondo!"
  PO files containing translations for an application must be stored in a
  directory (by default it's `priv/gettext`) that has the following struture:
      gettext directory
      └─ locale
         └─ LC_MESSAGES
            ├─ domain_1.pob
            ├─ domain_2.po
            └─ domain_3.po
  Here, `locale` is the locale of the translations (for example, `en_US`),
  `LC_MESSAGES` is a fixed directory, and `domain_i.po` are PO files containing
  domain-scoped translations. For more information on domains, check out the
  "Domains" section below.
  A concrete example of such a directory structure could look like this:
      priv/gettext
      └─ en_US
      |  └─ LC_MESSAGES
      |     ├─ default.po
      |     └─ errors.po
      └─ it
         └─ LC_MESSAGES
            ├─ default.po
            └─ errors.po
  By default, Gettext expects translations to be stored under the `priv/gettext`
  directory of an application. This behaviour can be changed by specifying a
  `:priv` option when using `Gettext`:
      # Look for translations in my_app/priv/translations instead of
      # my_app/priv/gettext
      use Gettext, otp_app: :my_app, priv: "priv/translations"
  The translations directory specified by the `:priv` option should be a directory
  inside `priv/`, otherwise some things (like `mix compile.gettext`) won't work
  as expected.
  ## Locale
  At runtime, all gettext-related functions and macros that do not explicitly
  take a locale as an argument read the locale from the backend locale and
  fallbacks to Gettext's locale.
  `Gettext.put_locale/1` can be used to change the locale of all backends for
  the current Elixir process. That's the preferred mechanism for setting the
  locale at runtime. `Gettext.put_locale/2` can be used when you want to set the
  locale of one specific Gettext backend without affecting other Gettext
  backends.
  Similarly, `Gettext.get_locale/0` gets the locale for all backends in the
  current process. `Gettext.get_locale/1` gets the locale of a specific backend
  for the current process. Check their documentation for more information.
  Locales are expressed as strings (like `"en"` or `"fr"`); they can be
  arbitrary strings as long as they match a directory name. As mentioned above,
  the locale is stored **per-process** (in the process dictionary): this means
  that the locale must be set in every new process in order to have the right
  locale available for that process. Pay attention to this behaviour, since not
  setting the locale *will not* result in any errors when `Gettext.get_locale/0`
  or `Gettext.get_locale/1` are called; the default locale will be
  returned instead.
  To decide which locale to use, each gettext-related function in a given
  backend follows these steps:
    * if there is a backend-specific locale for the given backend for this
      process (see `put_locale/2`), use that, otherwise
    * if there is a global locale for this process (see `put_locale/1`), use
      that, otherwise
    * if there is a backend-specific default locale in the configuration for
      that backend's `:otp_app` (see the "Default locale" section below), use
      that, otherwise
    * use the default global Gettext locale (see the "Default locale" section
      below)
  ### Default locale
  The global Gettext default locale can be configured through the
  `:default_locale` key of the `:gettext` application:
      config :gettext, :default_locale, "fr"
  By default the global locale is `"en"`. See also `get_locale/0` and
  `put_locale/1`.
  If for some reason a backend requires with a different `:default_locale`
  than all other backends, you can set the `:default_locale` inside the
  backend configuration, but this approach is generally discouraged as
  it makes it hard to track which locale each backend is using:
      config :my_app, MyApp.Gettext, default_locale: "fr"
  ## Gettext API
  There are two ways to use gettext:
    * using macros from your own gettext module, like `MyApp.Gettext`
    * using functions from the `Gettext` module
  These two approaches are different and each one has its own use case.
  ### Using macros
  Each module that calls `use Gettext` is usually referred to as a "Gettext
  backend", as it implements the `Gettext.Backend` behaviour. When a module
  calls `use Gettext`, the following macros are automatically
  defined inside it:
    * `gettext/2`
    * `dgettext/3`
    * `ngettext/4`
    * `dngettext/5`
    * `gettext_noop/1`, `dgettext_noop/2`, `ngettext_noop/3`, `dngettext_noop/4`
  Supposing the caller module is `MyApp.Gettext`, the macros mentioned above
  behave as follows:
    * `gettext(msgid, bindings \\ %{})` -
      like `Gettext.gettext(MyApp.Gettext, msgid, bindings)`
    * `dgettext(domain, msgid, bindings \\ %{})` -
      like `Gettext.dgettext(MyApp.Gettext, domain, msgid, bindings)`
    * `ngettext(msgid, msgid_plural, n, bindings \\ %{})` -
      like `Gettext.ngettext(MyApp.Gettext, msgid, msgid_plural, n, bindings)`
    * `dngettext(domain, msgid, msgid_plural, n, bindings \\ %{})` -
      like `Gettext.dngettext(MyApp.Gettext, domain, msgid, msgid_plural, n, bindings)`
    * `*_noop` family of functions - used to mark translations for extraction
      without translating them; see the documentation for these macros in
      `Gettext.Backend`
  See also the `Gettext.Backend` behaviour for more detailed documentation about
  these macros.
  Using macros is preferred as gettext is able to automatically sync the
  translations in your code with PO files. This, however, imposes a constraint:
  arguments passed to any of these macros have to be strings **at compile
  time**. This means that they have to be string literals or something that
  expands to a string literal at compile time (for example, a module attribute like
  `@my_string "foo"`).
  These are all valid uses of the gettext macros:
      Gettext.put_locale MyApp.Gettext, "it"
      MyApp.Gettext.gettext "Hello world"
      #=> "Ciao mondo"
      @msgid "Hello world"
      MyApp.Gettext.gettext @msgid
      #=> "Ciao mondo"
  The `gettext`/`dgettext`/`ngettext`/`dngettext` macros raise an
  `ArgumentError` exception if they receive a `domain`, `msgid`, or
  `msgid_plural` that doesn't expand to a string at compile time:
      msgid = "Hello world"
      MyApp.Gettext.gettext msgid
      #=> ** (ArgumentError) msgid must be a string literal
  Using compile-time strings isn't always possible. For this reason,
  the `Gettext` module provides a set of functions as well.
  ### Using functions
  If compile-time strings cannot be used, the solution is to use the functions
  in the `Gettext` module instead of the macros described above. These functions
  perfectly mirror the macro API, but they all expect a module name as the first
  argument. This module has to be a module which calls `use Gettext`. For example:
      defmodule MyApp.Gettext do
        use Gettext, otp_app: :my_app
      end
      Gettext.put_locale MyApp.Gettext, "pt_BR"
      msgid = "Hello world"
      Gettext.gettext(MyApp.Gettext, msgid)
      #=> "Olá mundo"
  While using functions from the `Gettext` module yields the same results as
  using macros (with the added benefit of dynamic arguments), all the
  compile-time features mentioned in the previous section are lost.
  ## Domains
  The `dgettext` and `dngettext` functions/macros also accept a *domain* as one
  of the arguments. The domain of a translation is determined by the name of the
  PO file that contains that translation. For example, the domain of
  translations in the `it/LC_MESSAGES/errors.po` file is `"errors"`, so those
  translations would need to be retrieved with `dgettext` or `dngettext`:
      MyApp.Gettext.dgettext "errors", "Error!"
      #=> "Errore!"
  When `gettext` or `ngettext` are used, the `"default"` domain is used.
  ## Interpolation
  All `*gettext` functions and macros provided by gettext support interpolation.
  Interpolation keys can be placed in `msgid`s or `msgid_plural`s with by
  enclosing them in `%{` and `}`, like this:
      "This is an %{interpolated} string"
  Interpolation bindings can be passed as an argument to all of the `*gettext`
  functions/macros. For example, given the following PO file for the `"it"`
  locale:
      msgid "Hello, %{name}!"
      msgstr "Ciao, %{name}!"
  interpolation can be done like follows:
      Gettext.put_locale MyApp.Gettext, "it"
      MyApp.Gettext.gettext "Hello, %{name}!", name: "Meg"
      #=> "Ciao, Meg!"
  Interpolation keys that are in a string but not in the provided bindings
  result in a `Gettext.Error` exception:
      MyApp.Gettext.gettext "Hello, %{name}!"
      #=> ** (Gettext.Error) missing interpolation keys: name
  Keys that are in the interpolation bindings but that don't occur in the string
  are ignored. Interpolations in gettext are often expanded at compile time,
  ensuring a low performance cost when running them at runtime.
  ## Pluralization
  Pluralization in gettext for Elixir works very similar to how pluralization
  works in GNU gettext. The `*ngettext` functions/macros accept a `msgid`, a
  `msgid_plural` and a count of elements; the right translation is chosen based
  on the **pluralization rule** for the given locale.
  For example, given the following snippet of PO file for the `"it"` locale:
      msgid "One error"
      msgid_plural "%{count} errors"
      msgstr[0] "Un errore"
      msgstr[1] "%{count} errori"
  the `ngettext` macro can be used like this:
      Gettext.put_locale MyApp.Gettext, "it"
      MyApp.Gettext.ngettext "One error", "%{count} errors", 3
      #=> "3 errori"
  The `%{count}` interpolation key is a special key since it gets replaced by
  the number of elements argument passed to `*ngettext`, like if the `count: 3`
  key-value pair were in the interpolation bindings. Hence, never pass the
  `count` key in the bindings:
      # `count: 4` is ignored here
      MyApp.Gettext.ngettext "One error", "%{count} errors", 3, count: 4
      #=> "3 errori"
  You can specify a "pluralizer" module via the `:plural_forms` option in the
  configuration for each Gettext backend.
      defmodule MyApp.Gettext do
        use Gettext, otp_app: :my_app, plural_forms: MyApp.PluralForms
      end
  To learn more about pluralization rules, plural forms and what they mean to
  Gettext check the documentation for `Gettext.Plural`.
  ## Missing translations
  When a translation is missing in the specified locale (both with functions as
  well as with macros), the argument is returned:
    * in case of calls to `gettext`/`dgettext`, the `msgid` argument is returned
      as is;
    * in case of calls to `ngettext`/`dngettext`, the `msgid` argument is
      returned in case of a singular value and the `msgid_plural` is returned in
      case of a plural value (following the English pluralization rule).
  For example:
      Gettext.put_locale MyApp.Gettext, "foo"
      MyApp.Gettext.gettext "Hey there"
      #=> "Hey there"
      MyApp.Gettext.ngettext "One error", "%{count} errors", 3
      #=> "3 errors"
  ### Empty translations
  When a `msgstr` is empty (`""`), the translation is considered missing and the
  behaviour described above for missing translation is applied. A plural
  translation is considered to have an empty `msgstr` if at least one
  translation in the `msgstr` is empty.
  ## Contexts
  The GNU Gettext implementation supports
  [*contexts*](https://www.gnu.org/software/gettext/manual/html_node/Contexts.html),
  which are a way to "contextualize" translations. For example, in English, the
  word "file" could be used both as a noun or as a verb. Contexts can be used to
  solve similar problems: one could have a "imperative_verbs" context and a
  "nouns" context as to avoid ambiguity. However, contexts increase the
  complexity of Gettext and would increase the complexity of the implementation
  of Gettext for Elixir, and for this reason we decided to not support them. The
  problem they try to solve can still be solved just using domains: for example,
  one could have the `default-imperative_verbs` domain and the `default-nouns`
  domain and use the `d(n)gettext` family of macros/functions, and the final
  result would be similar
  ## Compile-time features
  As mentioned above, using the gettext macros (as opposed to functions) allows
  gettext to operate on those translations *at compile-time*. This can be used
  to extract translations from the source code into POT files automatically
  (instead of having to manually add translations to POT files when they're added
  to the source code). The `gettext.extract` does exactly this: whenever there
  are new translations in the source code, running `gettext.extract` syncs the
  existing POT files with the changed code base. Read the documentation for
  `Mix.Tasks.Gettext.Extract` for more information on the extraction process.
  POT files are just *template* files and the translations in them do not
  actually contain translated strings. A POT file looks like this:
      # The msgstr is empty
      msgid "hello, world"
      msgstr ""
  Whenever a POT file changes, it's likely that developers (or translators) will
  want to update the corresponding PO files for each locale. To do that, gettext
  provides the `gettext.merge` Mix task. For example, running:
      mix gettext.merge priv/gettext --locale pt_BR
  will update all the PO files in `priv/gettext/pt_BR/LC_MESSAGES` with the new
  version of the POT files in `priv/gettext`. Read more about the merging
  process in the documentation for `Mix.Tasks.Gettext.Merge`.
  Finally, gettext is able to recompile modules that call `use Gettext` whenever
  PO files change. To enable this feature, the `:gettext` compiler needs to be
  added to the list of Mix compilers. In `mix.exs`:
      def project do
        [compilers: [:gettext] ++ Mix.compilers]
      end
  ## Configuration
  ### `:gettext` configuration
  The `:gettext` application supports the following configuration options:
    * `:default_locale` - a string which specifies the default global Gettext
      locale to use for all backends. See the "Locale" section for more
      information on backend-specific, global, and default locales.
  ### Backend configuration
  A **Gettext backend** supports some options to be configured. These options
  can be configured in two ways: either by passing them to `use Gettext` (hence
  at compile time):
      defmodule MyApp.Gettext do
        use Gettext, options
      end
  or by using Mix configuration, configuring the key corresponding to the
  backend in the configuration for your application:
      # For example, in config/config.exs
      config :my_app, MyApp.Gettext, options
  Note that the `:otp_app` option (an atom representing an OTP application) has
  to always be present and has to be passed to `use Gettext` because it's used
  to determine the application to read the configuration of (`:my_app` in the
  example above); for this reason, `:otp_app` can't be configured via the Mix
  configuration. This option is also used to determine the application's
  directory where to search translations in.
  The following is a comprehensive list of supported options:
    * `:priv` - a string representing a directory where translations will be
      searched. The directory is relative to the directory of the application
      specified by the `:otp_app` option. It is recommended to always have
      this directory inside `"priv"`, otherwise some features like the
      "mix compile.gettext" won't work as expected. By default it's
      `"priv/gettext"`.
    * `:plural_forms` - a module which will act as a "pluralizer". For more
      information, look at the documentation for `Gettext.Plural`.
    * `:default_locale` - a string which specifies the default locale to use for
      the given backend.
    * `:one_module_per_locale` - instead of bundling all locales into a single
      module, this option makes Gettext build one internal module per locale.
      This reduces compilation times and beam file sizes for large projects.
      This option requires Elixir v1.6.
  ### Mix tasks configuration
  You can configure Gettext Mix tasks under the `:gettext` key in the
  configuration returned by `project/0` in `mix.exs`:
      def project() do
        [app: :my_app,
         # ...
         gettext: [...]]
      end
  The following is a list of the supported configuration options:
    * `:fuzzy_threshold` - the default threshold for the Jaro distance measuring
      the similarity of translations. Look at the documentation for the `mix
      gettext.merge` task (`Mix.Tasks.Gettext.Merge`) for more information on
      fuzzy translations.
    * `:excluded_refs_from_purging` - a regex that is matched against translation
      references. Gettext will preserve all translations in all POT files that
      have a matching reference. You can use this pattern to prevent Gettext from
      removing translations that you have extracted using another tool.
    * `:compiler_po_wildcard` - a binary that specifies the wildcard that the
      `:gettext` compiler will use to find changed PO files in order to recompile
      their respective Gettext backends. This wildcard has to be relative to the
      `"priv"` directory of your application. Defaults to
      `"gettext/*/LC_MESSAGES/*.po"`.
    * `:write_reference_comments` - a boolean that specifies whether reference
      comments should be written when outputting PO(T) files. If this is `false`,
      reference comments will not be written when extracting translations or merging
      translations, and the ones already found in files will be discarded.
  """
  # use ElixirJourney.Exercise,
  #     slug: "hello_world",
  #     name: "Hello World",
  #     exercise_dir: "exercises/",
  #     exercise_file: "hello_world.exs",
  #     sulution_dir: "solutions/",
  #     solution_file: "solution.exs"


  @doc """
  Journey DSL
  {keyword} [params] == response
  test "Hello world journey" do
    solution == "Hello World"
  end

  """

  def exec do
  end
end
