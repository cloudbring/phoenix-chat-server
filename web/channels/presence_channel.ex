defmodule ElixirChat.PresenceChannel do
  use Phoenix.Channel
  alias ElixirChat.TeacherRosterServer, as: Teachers
  alias ElixirChat.StudentRosterServer, as: Students

  def join(socket, "global", %{"userId" => id, "role" => "teacher"}) do
    Teachers.add %{id: id}
    socket = assign(socket, :id, id)

    broadcast_status socket

    {:ok, socket}
  end

  def join(socket, "global", %{"userId" => id, "role" => "student"}) do
    Students.add %{id: id}
    socket = assign(socket, :id, id)

    broadcast_status socket

    {:ok, socket}
  end

  def leave(socket, "global") do
    IO.puts "leaving"

    student_id = socket.assigns[:id]
    Students.remove student_id

    broadcast_status socket

    socket
  end

  def event(socket, "claim:student", %{"teacherId" => teacher_id}) do
    if Teachers.can_accept_more_students?(teacher_id) do
      IO.puts "claiming student"
    end

    socket
  end

  def broadcast_status(socket) do
    data = %{
      teachers: Teachers.stats,
      students: Students.stats
    }

    broadcast socket, "user:status", data
  end
end
