/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tiagovr4 <tiagovr4@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/09 18:39:44 by tiagovr4          #+#    #+#             */
/*   Updated: 2025/06/23 09:02:59 by tiagovr4         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../minitalk.h"

static char	*g_buffer = NULL;

/* static void	show_and_release(void)
{
	ft_printf("%s\n", g_buffer);
	free(g_buffer);
	g_buffer = NULL;
} */

// this funtion reconstructs the original message
static void	handle_message(int sig)
{
	static unsigned char	received_char = 0;
	static int				bit_counter = 0;
	char					temp[2];
	char					*joined;

	if (sig == SIGUSR1)
		received_char |= (1 << bit_counter);
	bit_counter++;
	if (bit_counter == 8)
	{
		temp[0] = received_char;
		temp[1] = '\0';
		if (!g_buffer)
			g_buffer = ft_strdup("");
		joined = ft_strjoin(g_buffer, temp);
		free(g_buffer);
		g_buffer = joined;
		if (received_char == '\0')
		{
			//show_and_release();
			ft_printf("%s\n", g_buffer);
			free(g_buffer);
			g_buffer = NULL;
		}
			bit_counter = 0;
			received_char = 0;
	}
}

int	main(void)
{
	ft_printf("Server PID: %d\n", getpid());
	signal(SIGUSR1, handle_message);
	signal(SIGUSR2, handle_message);
	while (1)
		pause();
	return (0);
}
