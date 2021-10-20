defmodule Luvbot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    # Algumas funções de Teste apenas :)
    cond do
      String.starts_with?(msg.content, "!echo") ->
        # Repete exatamente o que você falou
        aux = String.split(msg.content, " ", parts: 2)
        Api.start_typing(msg.channel_id)
        Api.create_message(msg.channel_id, "#{Enum.at(aux, 1)}")

      String.starts_with?(msg.content, "!noisebg") ->
        aux = String.split(msg.content, " ", parts: 2)
        noisefy(Enum.at(aux, 1), msg)

      String.starts_with?(msg.content, "!monsterize") ->
        avatar_random(msg)

      String.starts_with?(msg.content, "!demonsterize") ->
        avatar_normal(msg)

      String.starts_with?(msg.content, "!lucky") ->
        aux = String.split(msg.content, " ", parts: 2)

        if Enum.count(aux) > 1 do
          ball8(msg)
        else
          Api.start_typing(msg.channel_id)

          Api.create_message(
            msg.channel_id,
            "If you don't ask, I'll not answer :smirk:"
          )
        end

      String.starts_with?(msg.content, "!trivia") ->
        trivia(msg)

      String.starts_with?(msg.content, "!qrcode") ->
        qrcodefy(msg)

      String.starts_with?(msg.content, "!") ->
        # Erro ao reconhecer comando
        Api.start_typing(msg.channel_id)
        Api.create_message(msg.channel_id, "Sorry, I didin't found this command! :sob:")

      # String.starts_with?(msg.content, "!math") ->
      #   aux = String.split(msg.content, " ", parts: 3)

      #   if Enum.count(aux) == 3 do
      #     op = String.capitalize(String.downcase(Enum.at(aux, 1)))
      #     exp = String.downcase(Enum.at(aux, 2))

      #     value = arithimatical_handler(op, aux)

      #     if value == "invalid" do
      #       Api.start_typing(msg.channel_id)
      #       Api.create_message(msg.channel_id, "Something is strange with your operation. Correct it and try again :smile:")
      #     else
      #       Api.start_typing(msg.channel_id)
      #       Api.create_message(msg.channel_id, "Here it goes!")
      #       Api.start_typing(msg.channel_id)
      #       Api.create_message(msg.channel_id, "The result for #{exp} for the #{op} operation is #{value}!")
      #     end

      #   else
      #     Api.start_typing(msg.channel_id)
      #     Api.create_message(msg.channel_id, "You do need math classes! :smirk:")
      #     Api.start_typing(msg.channel_id)
      #     Api.create_message(msg.channel_id, "I need 3 arguments, the operation and the expression, no more, nor less")
      #   end

      # String.starts_with?(msg.content, "!twitter") ->
      #   aux = String.split(msg.content, " ", parts: 2)

      #   if Enum.count(aux) > 1 do
      #     twitter_handler(Enum.at(aux, 1), msg)
      #   else
      #     Api.start_typing(msg.channel_id)
      #     Api.create_message(
      #       msg.channel_id,
      #       "This will not work! Try \"!twitter -follow <username>\" or \"!twitter -unfollow <username>\" instead!"
      #     )
      #   end

      # Todo o resto que não for comando
      true ->
        :ok
    end
  end

  def handle_event(_) do
    :ok
  end

  defp ball8(msg) do
    {:ok, response} = HTTPoison.get("https://yesno.wtf/api")

    body = Poison.decode!(response.body)

    answ = String.capitalize(body["answer"])
    forced = body["forced"]
    img = body["image"]

    Api.start_typing(msg.channel_id)

    if forced do
      Api.create_message(
        msg.channel_id,
        "STOP ASKING :rage:"
      )
    else
      Api.create_message(
        msg.channel_id,
        "#{answ}"
      )

      Api.create_message(
        msg.channel_id,
        "#{img}"
      )
    end
  end

  defp noisefy(hex, msg) do
    {:ok, res} = HTTPoison.get("https://php-noise.com/noise.php?hex=#{hex}&json")

    body = Poison.decode!(res.body)
    uri = body["uri"]

    Api.start_typing(msg.channel_id)

    Api.create_message(
      msg.channel_id,
      "Here's your noise! #{uri}"
    )
  end

  defp avatar_normal(msg) do
    Api.start_typing(msg.channel_id)

    Api.create_message(
      msg.channel_id,
      "OMG finally :cry:"
    )

    {:ok, file} = File.read("images/Pic.png")
    base64 = Base.encode64(file)

    Api.modify_current_user(avatar: "data:image/png;base64, #{base64}")

    Api.start_typing(msg.channel_id)

    Api.create_message(
      msg.channel_id,
      "Look at this! Much better :smile:"
    )
  end

  defp avatar_random(msg) do
    Api.start_typing(msg.channel_id)

    Api.create_message(
      msg.channel_id,
      "Okay, #{msg.author.username}! Randomizing my Avatar..."
    )

    {:ok, res} = HTTPoison.get("https://app.pixelencounter.com/api/basic/monsters/random/png")

    base64 = Base.encode64(res.body)

    Api.modify_current_user(avatar: "data:image/png;base64, #{base64}")

    Api.start_typing(msg.channel_id)

    Api.create_message(
      msg.channel_id,
      "Wow, I look so... monsterious :3"
    )
  end

  defp qrcodefy(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    p_text = Enum.at(aux, 1)

    auxp_text = String.split(p_text, " ", parts: 2)
    param = Enum.at(auxp_text, 0)
    s_text = Enum.at(auxp_text, 1)

    case param do
      "-create" ->
        {:ok, res} =
          HTTPoison.get("http://api.qrserver.com/v1/create-qr-code/?data=#{s_text}&size=300x300")

        File.write!("temp/qrcode.png", res.body)

        Api.start_typing(msg.channel_id)

        Api.create_message(
          msg.channel_id,
          file: "temp/qrcode.png"
        )

      "-decode" ->
        file_url = Enum.at(msg.attachments, 0).url

        if file_url == nil do
          Api.start_typing(msg.channel_id)

          Api.create_message(
            msg.channel_id,
            "There's no attachments! :D"
          )
        else
          {:ok, res} =
            HTTPoison.get("http://api.qrserver.com/v1/read-qr-code/?fileurl=#{file_url}")

          body = Poison.decode!(res.body)

          Enum.each(
            body,
            fn b ->
              content = b["symbol"]

              Enum.each(
                content,
                fn symbol ->
                  data = symbol["data"]

                  Api.start_typing(msg.channel_id)

                  Api.create_message(
                    msg.channel_id,
                    "Your QRCode content: \"#{data}\""
                  )
                end
              )
            end
          )
        end

      _ ->
        Api.start_typing(msg.channel_id)

        Api.create_message(
          msg.channel_id,
          "Your qrcode specs are strange! :("
        )
    end
  end

  defp trivia(msg) do
    # Jogar Trivia
    aux = String.split(msg.content, " ", parts: 2)

    case Enum.at(aux, 1) do
      "help" ->
        Api.start_typing(msg.channel_id)

        Api.create_message(
          msg.channel_id,
          "Type **\"!trivia <No. Questions> <Dificulty> <Type>\"** to start the trivia!"
        )

        Api.start_typing(msg.channel_id)

        Api.create_message(
          msg.channel_id,
          "*All fields are mandatory!*"
        )

        Api.start_typing(msg.channel_id)

        Api.create_message(
          msg.channel_id,
          "**No. Questions** -> Min 1 Max 30"
        )

        Api.start_typing(msg.channel_id)

        Api.create_message(
          msg.channel_id,
          "**Difficulty** -> Easy, Medium and Hard"
        )

        Api.start_typing(msg.channel_id)

        Api.create_message(
          msg.channel_id,
          "**Type** -> Multiple, Boolean(true or false)"
        )

      _ ->
        specs = String.split(Enum.at(aux, 1))

        if Enum.count(specs) == 3 do
          # tratar erros

          # HTTP Request
          HTTPoison.start()

          amount = Enum.at(specs, 0)
          difficulty = Enum.at(specs, 1)
          type = Enum.at(specs, 2)

          {:ok, response} =
            HTTPoison.get(
              "https://opentdb.com/api.php?amount=#{amount}&difficulty=#{difficulty}&type=#{type}"
            )

          body = Poison.decode!(response.body)

          show_questions(msg, body["results"], 0)
        else
          Api.start_typing(msg.channel_id)

          Api.create_message(
            msg.channel_id,
            "Your Trivia Specs are Invalid. Please try again or check *\"!trivia help\"*"
          )
        end
    end
  end

  defp show_questions(msg, questions, pos) do
    if Enum.count(questions) > pos do
      question = Enum.at(questions, pos)

      answ = Enum.concat(question["incorrect_answers"], [question["correct_answer"]])
      correct = question["correct_answer"]

      Enum.shuffle(answ)

      Api.start_typing(msg.channel_id)

      Api.create_message(
        msg.channel_id,
        "
      ================================================
      **Category**: #{question["category"]}
      **Question**: #{question["question"]} :thinking:
      >>> Answers: #{Enum.join(answ, ", ")}
      "
      )

      {:ok, dm_id} = Api.create_dm(msg.author.id)

      Api.create_message(
        dm_id.id,
        "Hey, Listen! :sparkles:
      I have your answer!"
      )

      Api.create_message(
        dm_id.id,
        "Question: \"#{question["question"]}\"
      Correct Answer! **#{correct}** :wink:"
      )

      show_questions(msg, questions, pos + 1)
    end
  end

  # defp arithimatical_handler(op, exp) do

  #   normal_op = String.downcase(op)

  #   url = "https://newton.now.sh/api/v2/"

  #   case normal_op do
  #     "simplify" ->
  #       {:ok, response} = HTTPoison.get("#{url}simplify/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "factor" ->
  #       {:ok, response} = HTTPoison.get("#{url}factor/#{exp}")
  #       IO.puts(response.body)
  #     "derive" ->
  #       {:ok, response} = HTTPoison.get("#{url}derive/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "integrate" ->
  #       {:ok, response} = HTTPoison.get("#{url}integrate/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "find0" ->
  #       {:ok, response} = HTTPoison.get("#{url}zeroes/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "findtan" ->
  #       {:ok, response} = HTTPoison.get("#{url}tangent/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "areaundercurve" ->
  #       {:ok, response} = HTTPoison.get("#{url}area/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "sin" ->
  #       {:ok, response} = HTTPoison.get("#{url}sin/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "cos" ->
  #       {:ok, response} = HTTPoison.get("#{url}cos/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "tan" ->
  #       {:ok, response} = HTTPoison.get("#{url}tan/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "arcsin" ->
  #       {:ok, response} = HTTPoison.get("#{url}arcsin/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "arccos" ->
  #       {:ok, response} = HTTPoison.get("#{url}arccos/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "arctan" ->
  #       {:ok, response} = HTTPoison.get("#{url}arctan/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "absolute" ->
  #       {:ok, response} = HTTPoison.get("#{url}abs/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #     "log" ->
  #       {:ok, response} = HTTPoison.get("#{url}log/#{exp}")
  #       body = Poison.decode!(response.body)
  #       body["result"]
  #       _ ->
  #         "invalid"
  #   end

  # end

  # defp twitter_handler(cmd, msg) do
  #   cond do
  #     String.starts_with?(cmd, "-tweet") ->
  #       aux = String.split(cmd, " ", parts: 2)

  #       if Enum.count(aux) > 1 do
  #         twitter_tweet(Enum.at(aux, 1))
  #       else
  #         Api.create_message(
  #           msg.channel_id,
  #           "This will not work! Try \"!twitter -follow <username>\" or \"!twitter -unfollow <username>\" instead!"
  #         )
  #       end

  #     String.starts_with?(cmd, "-follow") ->
  #       aux = String.split(cmd, " ", parts: 2)

  #       if Enum.count(aux) > 1 do
  #         twitter_follow(Enum.at(aux, 1), msg)
  #       else
  #         Api.create_message(
  #           msg.channel_id,
  #           "This will not work! Try \"!twitter -follow <username>\" or \"!twitter -unfollow <username>\" instead!"
  #         )
  #       end

  #     String.starts_with?(cmd, "-unfollow") ->
  #       aux = String.split(cmd, " ", parts: 2)

  #       if Enum.count(aux) > 1 do
  #         twitter_unfollow(Enum.at(aux, 1), msg)
  #       else
  #         Api.create_message(
  #           msg.channel_id,
  #           "This will not work! Try \"!twitter -follow <username>\" or \"!twitter -unfollow <username>\" instead!"
  #         )
  #       end
  #   end
  # end

  # defp twitter_tweet(tweet) do
  #   url = "https://api.twitter.com/1.1/statuses/update.json?status=#{tweet}"
  #   header = twitter_auth_header(url)
  #   body = Poison.encode!(%{})

  #   {:ok, response} = HTTPoison.post(url, body, [header], [])

  #   IO.puts(response.body)
  # end

  # defp twitter_follow(cmd, msg) do
  #   split_cmd = String.split(cmd, " ", parts: 2)

  #   who = Enum.at(split_cmd, 0)

  #   if Enum.count(split_cmd) > 1 do
  #     watch = twitter_follow_watch(Enum.at(split_cmd, 1))

  #     url =
  #       "https://api.twitter.com/1.1/friendships/create.json?screen_name=#{who}&follow=#{watch}"

  #     header = twitter_auth_header(url)

  #     {:ok, res} = HTTPoison.get(url, [header])

  #     name = res["name"]
  #     username = res["screen_name"]

  #     Api.create_message(msg.channel_id, "Ghost_the_Kaos followed #{name}(#{username})")
  #   else
  #     url = "https://api.twitter.com/1.1/friendships/create.json?screen_name=#{who}"
  #     header = twitter_auth_header(url)

  #     {:ok, response} = HTTPoison.get(url, [header])

  #     res = Poison.decode!(response.body)

  #     IO.puts(response.body)

  #     name = res["name"]
  #     username = res["screen_name"]

  #     Api.create_message(msg.channel_id, "Ghost_the_Kaos followed #{name}(#{username})")
  #   end
  # end

  # defp twitter_unfollow(who, msg) do
  #   url = "https://api.twitter.com/1.1/friendships/destroy.json?screen_name=#{who}"

  #   header = twitter_auth_header(url)

  #   {:ok, response} = HTTPoison.get(url, [header])

  #   res = Poison.decode!(response.body)

  #   name = res["name"]
  #   username = res["screen_name"]

  #   Api.create_message(msg.channel_id, "Ghost_the_Kaos followed #{name}(#{username})")
  # end

  # defp twitter_follow_watch(cmd) do
  #   aux = String.split(cmd, " ", parts: 2)

  #   if Enum.count(aux) > 1 do
  #     cond do
  #       Enum.at(aux, 0) == "-watch" ->
  #         BoolCast.boolcast!(Enum.at(aux, 1))
  #     end
  #   else
  #     false
  #   end
  # end

  # defp twitter_auth_header(url) do
  #   try do
  #     creds =
  #       OAuther.credentials(
  #         consumer_key: Application.fetch_env!(:luvbot, :twitter_ck),
  #         consumer_secret: Application.fetch_env!(:luvbot, :twitter_cks),
  #         token: Application.fetch_env!(:luvbot, :twitter_tk),
  #         token_secret: Application.fetch_env!(:luvbot, :twitter_tks)
  #       )

  #     params = OAuther.sign("post", url, [], creds)
  #     {header, _req_params} = OAuther.header(params)

  #     header
  #   rescue
  #     e in RuntimeError -> e
  #   end
  # end
end
