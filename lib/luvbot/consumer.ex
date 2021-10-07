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
        Api.create_message(msg.channel_id, "#{Enum.at(aux, 1)}")

        String.starts_with?(msg.content, "!trivia") ->

          # Jogar Trivia
          aux = String.split(msg.content, " ", parts: 2)

          case Enum.at(aux, 1) do

            "help"->
              Api.start_typing(msg.channel_id)
              Api.create_message(msg.channel_id,
              "Type **\"!trivia <No. Questions> <Dificulty> <Type>\"** to start the trivia!")
              Api.start_typing(msg.channel_id)
              Api.create_message(msg.channel_id,
              "*All fields are mandatory!*")
              Api.start_typing(msg.channel_id)
              Api.create_message(msg.channel_id,
              "**No. Questions** -> Min 1 Max 30")
              Api.start_typing(msg.channel_id)
              Api.create_message(msg.channel_id,
              "**Difficulty** -> Easy, Medium and Hard")
              Api.start_typing(msg.channel_id)
              Api.create_message(msg.channel_id,
              "**Type** -> Multiple, Boolean(true or false)")

            _->
              specs = String.split(Enum.at(aux, 1))

              if Enum.count(specs) == 3 do

                # tratar erros

                # HTTP Request
                HTTPoison.start

                amount = Enum.at(specs, 0)
                difficulty = Enum.at(specs, 1)
                type = Enum.at(specs, 2)

                {:ok, response} = HTTPoison.get(
                  "https://opentdb.com/api.php?amount=#{amount}&difficulty=#{difficulty}&type=#{type}")

                  body = Poison.decode!(response.body)


                  show_questions(msg, body["results"], 0)

              else
                Api.start_typing(msg.channel_id)
                Api.create_message(msg.channel_id, "Your Trivia Specs are Invalid. Please try again or check *\"!trivia help\"*")
              end

          end

        String.starts_with?(msg.content, "!") ->
          #Erro ao reconhecer comando
          Api.create_message(msg.channel_id, "Sorry, I didin't found this command! :sob:")

        true -> :ok # Todo o resto que não for comando
    end
  end

  def handle_event(_) do
    :ok
  end

  defp show_questions(msg, questions, pos) do

    if Enum.count(questions) > pos do

      question = Enum.at(questions, pos)

      answ = Enum.concat(question["incorrect_answers"], [question["correct_answer"]])
      correct = question["correct_answer"]

      Enum.shuffle(answ)

      Api.start_typing(msg.channel_id)
      Api.create_message(msg.channel_id,
      "
      ================================================
      **Category**: #{question["category"]}
      **Question**: #{question["question"]} :thinking:
      >>> Answers: #{Enum.join(answ, ", ")}
      ")

      {:ok, dm_id} = Api.create_dm(msg.author.id)

      Api.create_message(dm_id.id,
      "Hey, Listen! :sparkles:
      I have your answer!")
      Api.create_message(dm_id.id,
      "Question: \"#{question["question"]}\"
      Correct Answer! **#{correct}** :wink:")


      show_questions(msg, questions, pos+1)
    end

  end

end
